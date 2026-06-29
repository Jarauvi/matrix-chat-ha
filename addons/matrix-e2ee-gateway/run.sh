#!/bin/bash
set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-/data/options.json}"

python3 - <<'PY' "$CONFIG_FILE"
import json
import os
import pathlib
import sys

config_path = sys.argv[1]
with open(config_path, encoding="utf-8") as handle:
    data = json.load(handle)


def pick(name: str, default: str = "") -> str:
    value = data.get(name, default)
    if value is None:
        return ""
    return str(value)


def bool_flag(name: str, default: bool = False) -> str:
    value = data.get(name, default)
    if isinstance(value, bool):
        return "1" if value else "0"
    return str(value)

os.environ["MATRIX_HOMESERVER"] = pick("matrix_homeserver")
os.environ["MATRIX_USER_ID"] = pick("matrix_user_id")
os.environ["MATRIX_ACCESS_TOKEN"] = pick("matrix_access_token")
os.environ["MATRIX_PASSWORD"] = pick("matrix_password")
os.environ["MATRIX_GATEWAY_TOKEN"] = pick("matrix_gateway_token")
os.environ["MATRIX_DEVICE_ID"] = pick("matrix_device_id")
os.environ["MATRIX_DEVICE_NAME"] = pick("matrix_device_name", "Home Assistant Matrix E2EE Gateway")
os.environ["MATRIX_STORE_PATH"] = pick("matrix_store_path", "/data/store")
os.environ["MATRIX_GATEWAY_HOST"] = pick("matrix_gateway_host", "0.0.0.0")
os.environ["MATRIX_GATEWAY_PORT"] = str(data.get("matrix_gateway_port", 8080))
os.environ["MATRIX_VERIFY_SSL"] = bool_flag("verify_ssl", True)
os.environ["MATRIX_IGNORE_UNVERIFIED_DEVICES"] = bool_flag("matrix_ignore_unverified_devices", True)
os.environ["MATRIX_INBOUND_WEBHOOK_URL"] = pick("matrix_inbound_webhook_url")
os.environ["MATRIX_INBOUND_SHARED_SECRET"] = pick("matrix_inbound_shared_secret")
os.environ["MATRIX_DEBUG_ENDPOINTS"] = bool_flag("matrix_debug_endpoints", False)
os.environ["LOG_LEVEL"] = pick("log_level", "INFO")

pathlib.Path(os.environ["MATRIX_STORE_PATH"]).mkdir(parents=True, exist_ok=True)
PY

exec python /app/gateway.py
