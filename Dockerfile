############
# builder stage
FROM centos:7 as builder

RUN yum --setopt tsflags=nodocs --setopt timeout=5 -y install epel-release \
 && yum --setopt tsflags=nodocs --setopt timeout=5 -y install \
    cryptopp-devel \
    gcc-c++ \
    gd-devel \
    libpng-devel \
    make \
    gcc \
    pkgconfig \
    zlib-devel

ADD https://www.vanheusden.com/entropybroker/eb-2.9.tgz /tmp/
WORKDIR /tmp/builder
RUN tar zxvf /tmp/eb-2.9.tgz
WORKDIR /tmp/builder/eb-2.9
RUN ./configure \
 && make \
        eb_client_file \
        eb_client_linux_kernel \
 && make install

############
# entropybroker-client

FROM centos:7

ENV BROKER_HOST none
ENV BROKER_PORT 55225
ENV CLIENT_USERNAME none
ENV CLIENT_PASSWORD none
ENV ENTROPY_STIR 5
ENV LOG_LEVEL 255

RUN yum --setopt tsflags=nodocs --setopt timeout=5 -y install \
    epel-release

RUN yum --setopt tsflags=nodocs --setopt timeout=5 -y install \
    cryptopp

# assert cryptopp successfully installed
RUN rpm -q cryptopp

RUN mkdir -p \
    /usr/local/entropybroker \
    /usr/local/entropybroker/etc \
    /usr/local/entropybroker/bin \
    /usr/local/entropybroker/var \
    /usr/local/entropybroker/var/run \
    /usr/local/entropybroker/var/cache

COPY --from=builder /usr/local/entropybroker/bin/eb_client_linux_kernel /usr/local/entropybroker/bin/eb_client_linux_kernel
COPY --from=builder /usr/local/entropybroker/bin/eb_client_file         /usr/local/entropybroker/bin/eb_client_file

RUN chown -R 0:0  /usr/local/entropybroker/etc /usr/local/entropybroker/var \
 && chmod -R 0700 /usr/local/entropybroker/etc /usr/local/entropybroker/var

COPY entropyclient.sh /usr/local/entropybroker/bin/entropyclient.sh
RUN chmod 0775 /usr/local/entropybroker/bin/entropyclient.sh

CMD ["/usr/local/entropybroker/bin/entropyclient.sh"]
