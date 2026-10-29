"""Create a fresh billing signing key without replacing legacy keys."""

from __future__ import annotations

import re
import secrets
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from app.services.license_service import (  # noqa: E402
    PRIVATE_KEY_PATH,
    PUBLIC_KEY_PATH,
    LicenseError,
    generate_license_keypair,
)


def set_env_values(path: Path, values: dict[str, str]) -> None:
    if not path.is_file():
        raise SystemExit(f"File konfigurasi tidak ditemukan: {path}")
    lines = path.read_text(encoding="utf-8").splitlines()
    for key, value in values.items():
        pattern = re.compile(rf"^\s*{re.escape(key)}\s*=.*$")
        matches = [index for index, line in enumerate(lines) if pattern.match(line)]
        replacement = f'{key}="{value}"'
        if matches:
            lines[matches[0]] = replacement
            for index in reversed(matches[1:]):
                del lines[index]
        else:
            lines.append(replacement)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    private_path = PRIVATE_KEY_PATH.with_name(
        "license-signing-private-v2.pem"
    )
    public_path = PUBLIC_KEY_PATH.with_name("license_public_key_v2.pem")
    if private_path.exists() or public_path.exists():
        raise SystemExit(
            "Kunci rotasi v2 sudah ada. Tidak ada file yang ditimpa."
        )

    passphrase = secrets.token_urlsafe(32)
    try:
        generate_license_keypair(private_path, public_path, passphrase)
    except LicenseError as exc:
        raise SystemExit(str(exc)) from exc

    set_env_values(
        PROJECT_ROOT / "server" / ".env",
        {
            "LICENSE_PRIVATE_KEY_PATH": str(private_path),
            "LICENSE_PRIVATE_KEY_PASSPHRASE": passphrase,
        },
    )
    print("Kunci signing v2 berhasil dibuat.")
    print(f"Private key tersimpan di luar repository: {private_path}")
    print(f"Public key aplikasi: {public_path}")
    print("Server .env diperbarui; passphrase tidak ditampilkan.")
    print(
        "Buat backup terenkripsi untuk private key dan simpan backup .env "
        "di lokasi yang aman. Jangan commit atau kirim keduanya."
    )


if __name__ == "__main__":
    main()
