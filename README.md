[![Snort3 Docker Image CI/CD](https://github.com/bengo237/snort-docker/actions/workflows/build-snort3.yml/badge.svg)](https://github.com/bengo237/snort-docker/actions/workflows/build-snort3.yml)
# Snort3 Docker  3.3.1.0

This repository provides a Dockerized deployment of [Snort3](https://www.snort.org/), a powerful network intrusion prevention system. It simplifies the use of Snort3 for Network Functions Virtualization (NFV).

## Docker Image Usage

> **Note:** Depending on your setup, you may need to use `sudo` for Docker commands.

To launch the Snort3 Docker container with full network access, use the following command:

```bash
docker run -it --rm --net=host ghcr.io/bengo237/snort3:latest /bin/bash
```

In some cases, you might need to add `--cap-add=NET_ADMIN` or `--privileged` to the Docker command. However, be cautious when using `--privileged` as it grants all capabilities to the container, which requires careful consideration.

## Verifying Snort Configuration

To validate the Snort configuration, run the following command:

```bash
snort -c /usr/local/etc/snort/snort.lua
```

## Additional Resources

For more information on Snort3 and its configuration, visit the [official Snort documentation](https://www.snort.org/documents).

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
