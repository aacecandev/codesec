FROM ubuntu:22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install --yes --quiet --no-install-recommends \
    curl=7.81.0-1ubuntu1.7 \
    jq=1.6-2.1ubuntu3 \
    ca-certificates=20211016ubuntu0.22.04.1 \
    git=1:2.34.1-1ubuntu1.6

# Download Gitleaks
RUN \
  curl -s "https://api.github.com/repos/zricethezav/gitleaks/releases/latest" \
  | jq '.assets[] | select(.name|match("linux_x64.tar.gz")) | .browser_download_url' \
  | xargs curl -LOs && \
  # Check checksums.txt agains standard input
  curl -s https://api.github.com/repos/zricethezav/gitleaks/releases/latest \
  | jq '.assets[] | select(.name|match("_checksums.txt")) | .browser_download_url' \
  | xargs curl -sL -o checksum && \
  sha256sum -c checksum --quiet --ignore-missing || exit 1 && \
  # Move to path
  tar -xzf gitleaks*linux_x64.tar.gz -C /usr/local/bin/ gitleaks

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY .gitleaks/* /.gitleaks/
COPY entrypoint.sh /entrypoint.sh

USER root

ENTRYPOINT ["/entrypoint.sh"]
