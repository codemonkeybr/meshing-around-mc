#!/bin/bash
set -e

# Guard: Docker bind-mount creates a directory when the host file doesn't exist.
# Detect that and bail early with a clear message.
if [ -d /app/config.ini ]; then
    echo "[entrypoint] ERROR: /app/config.ini is a directory, not a file." >&2
    echo "[entrypoint] On the host run: sudo rm -rf config.ini && cp config.template config.ini" >&2
    exit 1
fi

# Bootstrap config from template on first run
if [ ! -f /app/config.ini ]; then
    cp /app/config.template /app/config.ini
fi

INTERFACE_TYPE="${INTERFACE_TYPE:-serial}"
SERIAL_PORT="${SERIAL_PORT:-/dev/ttyUSB0}"

patch_section() {
    local section="$1"
    local key="$2"
    local value="$3"
    local tmp
    tmp=$(mktemp)
    if sed -n "/^\[${section}\]/,/^\[/p" /app/config.ini | grep -q "^${key} = "; then
        # Key exists in section — replace it
        sed "/^\[${section}\]/,/^\[/ s|^${key} = .*|${key} = ${value}|" /app/config.ini > "$tmp"
    else
        # Key missing — insert it right after the section header
        sed "/^\[${section}\]/a ${key} = ${value}" /app/config.ini > "$tmp"
    fi
    cp "$tmp" /app/config.ini
    rm "$tmp"
}

patch_interface_section() { patch_section "interface" "$1" "$2"; }
patch_general_section()   { patch_section "general"   "$1" "$2"; }

case "$INTERFACE_TYPE" in
    serial)
        patch_interface_section "type" "serial"
        patch_interface_section "port" "$SERIAL_PORT"
        echo "[entrypoint] Using serial interface on ${SERIAL_PORT}"
        ;;
    tcp)
        if [ -z "$TCP_HOST" ]; then
            echo "[entrypoint] ERROR: TCP_HOST must be set for INTERFACE_TYPE=tcp (e.g. 192.168.1.1:5052)" >&2
            exit 1
        fi
        patch_interface_section "type" "tcp"
        patch_interface_section "hostname" "$TCP_HOST"
        echo "[entrypoint] Using TCP interface at ${TCP_HOST}"
        ;;
    ble)
        if [ -z "$BLE_MAC" ]; then
            echo "[entrypoint] ERROR: BLE_MAC must be set for INTERFACE_TYPE=ble (e.g. AA:BB:CC:DD:EE:FF)" >&2
            exit 1
        fi
        patch_interface_section "type" "ble"
        patch_interface_section "mac" "$BLE_MAC"
        echo "[entrypoint] Using BLE interface at ${BLE_MAC}"
        ;;
    *)
        echo "[entrypoint] ERROR: Unknown INTERFACE_TYPE '${INTERFACE_TYPE}'. Use serial, tcp, or ble." >&2
        exit 1
        ;;
esac

# Optional: point the bot at an ollama instance
if [ -n "$OLLAMA_HOST" ]; then
    patch_general_section "ollamaHostName" "$OLLAMA_HOST"
    patch_general_section "ollama" "true"
    echo "[entrypoint] Ollama enabled at ${OLLAMA_HOST}"
fi

exec python /app/mesh_bot.py
