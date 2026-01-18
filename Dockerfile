##### devel base #####
FROM perl:5.38.5-slim-bookworm AS devel-base

ENV DEBIAN_FRONTEND=noninteractive

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN apt-get update \
    && apt-get install -y git curl build-essential ca-certificates \
    && apt-get install -y less procps lsof \
    && apt-get install -y libev4 libev-dev libffi8 libffi-dev \
    && apt-get install -y libzmq5 libzmq3-dev \
    && apt-get install -y openssl libssl3 libssl-dev libnss3 libnss3-dev \
    && apt-get install -y zlib1g zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*  # cleanup to save space

##### libraries #####
FROM devel-base AS libraries

ENV DEBIAN_FRONTEND=noninteractive

# add additional required library and packages here:
RUN apt-get update \
    && apt-get -y install libsqlite3-0 libsqlite3-dev \
    && apt-get -y install libyaml-0-2 libyaml-dev \
    && apt-get -y install libuv1 libuv1-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*  # cleanup to save space

##### devel #####
# add additional required library and packages for developement only #
FROM libraries AS devel

ENV DEBIAN_FRONTEND=noninteractive

## add locales and setup
RUN apt-get update \
    && apt-get -y install locales exuberant-ctags pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

RUN cpanm Carton Carmel

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

CMD ["/bin/bash"]

##### runtime base #####
FROM perl:5.38.5-slim-bookworm AS rt

ENV DEBIAN_FRONTEND=noninteractive
COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

#
# install required binary libs, MUST include libs from the **libraries** image
#
RUN apt-get update \
    && apt-get install -y curl ca-certificates less procps lsof \
    && apt-get install -y libev4 libffi8 \
    && apt-get install -y libzmq5 libzmq3-dev \
    && apt-get install -y openssl libssl3 libnss3  \
    && apt-get install -y zlib1g \
    && apt-get -y install libsqlite3-0 libyaml-0-2 libuv1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*  # cleanup to save space

CMD ["/bin/bash"]
