bash
#!/bin/bash

# ========================================================
# 1_jalankan_server.sh
# Menjalankan Server Billing POS dan Tunnel ngrok
# ========================================================

set -o pipefail

PORT="${1:-8001}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================================"
echo "       MENJALANKAN SERVER BILLING & NGROK TUNNEL"
echo "========================================================"

# 1. Jalankan script start_ngrok.sh
NGROK_SCRIPT="$REPO_ROOT/scripts/start_ngrok.sh"

if [[ ! -f "$NGROK_SCRIPT" ]]; then
    echo "[ERROR] scripts/start_ngrok.sh tidak ditemukan di $REPO_ROOT"
    exit 1
fi

echo ""
echo "[1/3] Menyiapkan tunnel ngrok dan konfigurasi .env..."

bash "$NGROK_SCRIPT" "$PORT"

if [[ $? -ne 0 ]]; then
    echo "[!] Gagal menjalankan ngrok tunnel."
    exit 1
fi

# 2. Restart Uvicorn server
echo ""
echo "[2/3] Memastikan server billing membaca konfigurasi terbaru..."

# Cari proses yang menggunakan port
PIDS=$(lsof -ti :"$PORT" 2>/dev/null || true)

if [[ -n "$PIDS" ]]; then
    while read -r PID; do
        if [[ "$PID" =~ ^[0-9]+$ ]] && [[ "$PID" != "$$" ]]; then
            echo "Menghentikan proses PID $PID untuk restart..."
            kill "$PID" 2>/dev/null || true
        fi
    done <<< "$PIDS"

    sleep 1
fi

# Tentukan Python virtual environment
PYTHON="$REPO_ROOT/venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
    PYTHON="$(command -v python3)"
fi

if [[ -z "$PYTHON" ]]; then
    echo "[ERROR] Python3 tidak ditemukan."
    exit 1
fi

# File log
SERVER_STDOUT="$REPO_ROOT/server_stdout.log"
SERVER_STDERR="$REPO_ROOT/server_stderr.log"

# Jalankan Uvicorn di background
cd "$REPO_ROOT" || exit 1

nohup "$PYTHON" -m uvicorn server.app.main:app \
    --host 127.0.0.1 \
    --port "$PORT" \
    > "$SERVER_STDOUT" \
    2> "$SERVER_STDERR" &

SERVER_PID=$!

echo "Uvicorn dijalankan dengan PID: $SERVER_PID"

# 3. Tunggu server siap
IS_READY=false

for ((i=0; i<30; i++)); do
    if timeout 1 bash -c "echo > /dev/tcp/127.0.0.1/$PORT" 2>/dev/null; then
        IS_READY=true
        break
    fi

    sleep 0.5
done

echo ""
echo "[3/3] Memeriksa status kesehatan server..."

if [[ "$IS_READY" == true ]]; then
    echo "[OK] Webserver billing aktif di http://127.0.0.1:$PORT"

    HEALTH=$(curl -sS --max-time 5 \
        "http://127.0.0.1:$PORT/health" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        echo "Health check: $HEALTH"
    else
        echo "[WARNING] Health check gagal."
    fi
else
    echo "[!] Server belum merespons di port $PORT."
    echo "Cek server_stderr.log."
fi

# 4. Ambil URL publik dari ngrok API
TUNNELS=$(curl -sS --max-time 3 \
    "http://127.0.0.1:4040/api/tunnels" 2>/dev/null)

PUBLIC_URL=$(echo "$TUNNELS" | python3 -c '
import sys, json

try:
    data = json.load(sys.stdin)
    for tunnel in data.get("tunnels", []):
        url = tunnel.get("public_url", "")
        if url.startswith("https://"):
            print(url)
            break
except Exception:
    pass
' 2>/dev/null)

if [[ -n "$PUBLIC_URL" ]]; then
    echo ""
    echo "========================================================"
    echo "              SERVER & NGROK SIAP DIGUNAKAN"
    echo "========================================================"
    echo "URL Web Publik : $PUBLIC_URL"
    echo "Webhook URL    : $PUBLIC_URL/webhooks/payment/midtrans"
    echo "Lokal Server   : http://127.0.0.1:$PORT"
    echo "Ngrok Web UI   : http://127.0.0.1:4040"
    echo "========================================================"
fi

echo ""
echo "Untuk menguji webhook:"
echo "bash 3_uji_endpoint.sh"

echo "Untuk menghentikan server:"
echo "bash 2_hentikan_server.sh"

echo ""
echo "Server berjalan di background."
echo "PID Uvicorn: $SERVER_PID"