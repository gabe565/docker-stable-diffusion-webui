#syntax=docker/dockerfile:1.4

FROM python:3.10.11-slim
WORKDIR /app

ARG REPO=AUTOMATIC1111/stable-diffusion-webui
ARG REF=v1.6.0

ARG USERNAME=sd
ARG UID=1000
ARG GID=$UID
RUN <<EOT
    set -eux
    groupadd --gid="$GID" "$USERNAME"
    useradd --create-home --uid="$UID" --gid="$GID" "$USERNAME"

    apt-get update
    apt-get install -y --no-install-recommends \
      git build-essential libgl1 libglib2.0-0 libtcmalloc-minimal4 wget
    rm -rf /var/lib/apt/lists/*

    git clone -q \
      --config=advice.detachedHead=false \
      --branch="$REF" \
      --depth=1 \
      "https://github.com/$REPO.git" .

    chown -R sd:sd /app
EOT
ENV venv_dir=/data/venv
ENV GRADIO_ANALYTICS_ENABLED=False
USER sd

WORKDIR /app
ENTRYPOINT ["./webui.sh", "--listen", "--data-dir=/data", "--enable-insecure-extension-access", "--disable-console-progressbars"]
CMD ["--medvram", "--xformers"]
