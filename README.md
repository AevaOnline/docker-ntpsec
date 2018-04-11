Getting Started
===============

This is a very basic build for a docker container to house NTPSec's ntpd daemon,
following instructions from https://docs.ntpsec.org/latest/quick.html

There are probably many things left to do...

First, download an ntpsec release and verify its signatures and SHA256 sum.
Then, build with the following command (replace 1.1.0 with the appropriate version).

```docker build --tag devananda/ntpsec:1.1.0 .```

Run with:

```docker run --name ntpd --privileged -ti -d devananda/ntpsec:1.1.0```

Notes
=====

Right now, this copies config files to `/etc/ntp.d/` during the image build process.

Alternatively, these could be mounted as a volume to enable easier editing at run-time.
