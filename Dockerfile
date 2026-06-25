# ── builder ───────────────────────────────────────────────────────────────────
# Compile C-extension packages (pycryptodome, ephem) here so the final image
# doesn't need build-essential or python3-dev.
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir --prefix=/install -r /tmp/requirements.txt

# ── final ─────────────────────────────────────────────────────────────────────
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    TZ=UTC

# tzdata  – timezone support for scheduler/timestamps
# ca-certificates – HTTPS calls (weather, RSS, APIs)
RUN apt-get update && apt-get install -y --no-install-recommends \
        tzdata \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy compiled packages from builder
COPY --from=builder /install /usr/local

WORKDIR /app
COPY . /app

RUN chmod +x /app/script/docker/entrypoint.sh

ENTRYPOINT ["/bin/bash", "/app/script/docker/entrypoint.sh"]
