FROM bitnami/minideb:jessie

WORKDIR /root
COPY ntpsec-1.1.0.tar.gz /root/

# prepare build environment
RUN tar -xzf ntpsec-1.1.0.tar.gz ;\
    rm ntpsec-1.1.0.tar.gz ;\
    cd ntpsec-1.1.0 ;\
    apt-get update ;\
    ./buildprep

# install ntpsec
RUN cd ntpsec-1.1.0 ;\
    ./waf configure && \
    ./waf build && \
    ./waf install

# install gpsd
RUN apt-get install -y gpsd

# create config files
RUN mkdir /etc/ntp.d && \
    mkdir /var/log/ntpstats && \
    mkdir /var/lib/ntp

COPY config /etc/ntp.d/config

# clean up
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/ntpsec-1.1.0

EXPOSE 123/udp

ENTRYPOINT /usr/local/sbin/ntpd -c /etc/ntp.d/config -n
