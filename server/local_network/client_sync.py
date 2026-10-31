import json
import os
from urllib import error, request


class LocalNetworkSyncClient:
    def __init__(self, server_url: str, username: str, password: str, device_code: str, device_name: str):
        self.server_url = server_url.rstrip("/")
        self.username = username
        self.password = password
        self.device_code = device_code
        self.device_name = device_name
        self.token = None
        self.device_token = None

    def _call(self, method: str, path: str, payload=None, headers=None):
        url = f"{self.server_url}{path}"
        data = None
        if payload is not None:
            data = json.dumps(payload).encode("utf-8")
        req = request.Request(url, data=data, method=method)
        req.add_header("Content-Type", "application/json")
        if headers:
            for key, value in headers.items():
                req.add_header(key, value)
        try:
            with request.urlopen(req, timeout=20) as resp:
                body = resp.read().decode("utf-8")
                return json.loads(body) if body else {}
        except error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="replace")
            try:
                parsed = json.loads(body)
                detail = parsed.get("detail", body)
            except Exception:
                detail = body
            raise RuntimeError(f"HTTP {exc.code}: {detail}") from exc

    def login(self):
        response = self._call(
            "POST",
            "/api/auth/login",
            {"username": self.username, "password": self.password},
        )
        self.token = response.get("token")
        if not self.token:
            raise RuntimeError("Login gagal: token tidak diterima")
        return response

    def register_device(self):
        if not self.token:
            raise RuntimeError("Belum login")
        response = self._call(
            "POST",
            "/api/device/register",
            {"device_code": self.device_code, "device_name": self.device_name},
            headers={"Authorization": f"Bearer {self.token}"},
        )
        self.device_token = response.get("api_token")
        return response

    def push_products(self, products):
        if not self.device_token:
            raise RuntimeError("Device belum terdaftar")
        return self._call(
            "POST",
            "/api/products/bulk",
            products,
            headers={"X-Device-Token": self.device_token},
        )

    def push_sales(self, sales):
        if not self.device_token:
            raise RuntimeError("Device belum terdaftar")
        return self._call(
            "POST",
            "/api/sales/bulk",
            sales,
            headers={"X-Device-Token": self.device_token},
        )

    def get_products(self):
        if not self.device_token:
            raise RuntimeError("Device belum terdaftar")
        return self._call("GET", "/api/products", headers={"X-Device-Token": self.device_token})

    def get_sync_status(self):
        if not self.device_token:
            raise RuntimeError("Device belum terdaftar")
        return self._call("GET", "/api/sync/status", headers={"X-Device-Token": self.device_token})


if __name__ == "__main__":
    server_url = os.getenv("POS_LAN_SERVER_URL", "http://192.168.1.10:8000")
    username = os.getenv("POS_LAN_USERNAME", "admin")
    password = os.getenv("POS_LAN_PASSWORD", "admin123")
    device_code = os.getenv("POS_LAN_DEVICE_CODE", "PC-001")
    device_name = os.getenv("POS_LAN_DEVICE_NAME", "Kasir 1")

    client = LocalNetworkSyncClient(server_url, username, password, device_code, device_name)
    client.login()
    client.register_device()

    print("Login sukses")
    print("Device token:", client.device_token)
    print("Status:", client.get_sync_status())
    print("Products:", client.get_products())
