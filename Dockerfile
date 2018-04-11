FROM bitnami/minideb:jessie

WORKDIR /root
COPY ntpsec-1.1.0.tar.gz /root/

# prepare build environment
RUN tar -xzvf ntpsec-1.1.0.tar.gz ;\
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

COPY config/ntp.drift /etc/ntp.d/drift
COPY config/ntp.logging /etc/ntp.d/logging
COPY config/ntp.security /etc/ntp.d/security
COPY config/ntp.pool /etc/ntp.d/pool

# clean up
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/ntpsec-1.1.0

ENTRYPOINT /usr/local/sbin/ntpd -n
