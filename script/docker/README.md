# How do I use this thing?
This is not a full turnkey setup for Docker yet?

> **Note:** The Docker setup below predates the MeshCore migration. The `meshtasticd` service runs the old Meshtastic daemon and is no longer used by the bot. Docker support for MeshCore is a work in progress.

`docker pull ghcr.io/spudgunman/meshing-around:main`

`docker network create meshing-around-network`

`docker compose run meshtasticd`

`docker compose run meshing-around`

`docker compose run debug-console`

`docker compose run ollama`

`docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=http://127.0.0.1:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main`


### Other Stuff
A cool tool to use with RAG creation with open-webui
- https://github.com/microsoft/markitdown
