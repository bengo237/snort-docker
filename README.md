[![Snort3 Docker Image CI/CD](https://github.com/bengo237/snort-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/bengo237/snort-docker/actions/workflows/docker-image.yml)
# Snort3 Docker Image 3.2.2.0

This repository offers a Dockerized deployment of [Snort3](https://www.snort.org/), a robust network intrusion prevention system, facilitating the utilization of Snort3 for Network Functions Virtualization (NFV).

## Verifying Snort Configuration

To validate the Snort configuration, execute the following command:

```bash
snort -c /usr/local/etc/snort/snort.lua 
```

## Docker Image Usage

Note: Depending on your setup, you may require `sudo` for Docker commands.

To launch the Snort3 Docker container with complete network access, utilize the following command:

```bash
docker run -it --rm --net=host ghcr.io/bengo237/snort3:latest /bin/bash
```

In certain scenarios, you might need to append `--cap-add=NET_ADMIN` or `--privileged` to the Docker command. Nonetheless, exercising caution is advised when using `--privileged` since it grants all capabilities to the container, warranting careful consideration.
