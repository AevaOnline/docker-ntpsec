Getting Started
===============

This is a very basic build for a docker container to house NTPSec's ntpd daemon,
following instructions from https://docs.ntpsec.org/latest/quick.html

There are probably many things left to do...

First, download an ntpsec release and verify its signatures and SHA256 sum.
Then, build with the following command (replace 1.1.0 with the appropriate version).

```docker build --tag devananda/ntpsec:1.1.0 .```

Run with:

```docker run --name ntpd --privileged --net=host -ti -d devananda/ntpsec:1.1.0```

Notes
=====

You must use `--net=host` because Docker does not NAT UDP traffic; without this
option, `ntpd` won't be able to receive any replies from other time servers.

Right now, this copies config file to `/etc/ntp.d/` during the image build
process. If you want to modify the config file for your instance, you should
mount it as a docker volume and override the `/etc/ntp.d/` directory, eg:

```docker run --name your-ntpd --privileged --net=host -v /path/to/config:/etc/ntp.d/ -ti -d devananda/ntpsec:1.1.0```
