# docker-snort snort3-3.1.53.0

[Snort](https://www.snort.org/) in Docker for Network Functions Virtualization (NFV)

# Docker Usage
You may need to run as `sudo`
Attach the snort in container to have full access to the network

```
$ docker run -it --rm --net=host ghcr.io/bengo237/snort3:latest /bin/bash
```

Or you may need to add --cap-add=NET_ADMIN or --privileged (unsafe)

```
$ docker run -it --rm --net=host --cap-add=NET_ADMIN ghcr.io/bengo237/snort3:latest /bin/bash
```


# Snort Usage

For testing it's work. Add this rule in the file at `/etc/snort/rules/local.rules`

```
alert icmp any any -> any any (msg:"Pinging...";sid:1000004;)
```

Running Snort and alerts output to the console (screen).

```
$ snort -i eth0 -c /etc/snort/etc/snort.conf -A console
```

Running Snort and alerts output to the UNIX socket

```
$ snort -i eth0 -A unsock -l /tmp -c /etc/snort/etc/snort.conf
```

Ping in the container then the alert message will show on the console

```
ping 8.8.8.8
```
