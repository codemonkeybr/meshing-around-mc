# Docker Setup

See [INSTALL.md — Docker Installation](../../INSTALL.md#docker-installation) for full setup instructions.

## Files

| File | Purpose |
|---|---|
| `../../Dockerfile` | Multi-stage build (python:3.12-slim); compiles C extensions in builder stage, keeps final image lean |
| `../../docker-compose.yml` | Defines the `meshbot` service with USB device passthrough, volume mounts, and optional ollama |
| `entrypoint.sh` | Bootstraps `config.ini` from template and applies interface settings from env vars at startup |
| `../../.dockerignore` | Excludes runtime artifacts (logs, data, config.ini, __pycache__) from the image |

## Entrypoint env vars

| Variable | Default | Description |
|---|---|---|
| `INTERFACE_TYPE` | `serial` | Radio interface: `serial`, `tcp`, or `ble` |
| `SERIAL_PORT` | `/dev/ttyUSB0` | Serial device path (serial mode only) |
| `TCP_HOST` | — | `host:port` for TCP mode (required when `INTERFACE_TYPE=tcp`) |
| `BLE_MAC` | — | MAC address for BLE mode (required when `INTERFACE_TYPE=ble`) |
| `OLLAMA_HOST` | — | Ollama URL e.g. `http://ollama:11434`; enables LLM when set |
