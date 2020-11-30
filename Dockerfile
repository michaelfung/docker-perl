##### base #####
FROM debian:buster AS base

ARG PERLVER="5.28.3"

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
SHELL ["/bin/bash", "-c"]
ENV PERLBREW_ROOT /opt/perlbrew

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN apt-get update \
    && apt-get install -y git curl build-essential ca-certificates locales \
    && apt-get install -y less procps lsof \
    && apt-get install -y libev4 libev-dev libffi6 libffi-dev \
    && apt-get install -y libzmq5 libzmq3-dev \
    && apt-get install -y openssl libssl1.1 libssl-dev libnss3 libnss3-dev \
    && apt-get install -y zlib1g zlib1g-dev \
    && apt-get install -y perlbrew \
    && \curl -L https://install.perlbrew.pl | bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*  # cleanup to save space

RUN source /opt/perlbrew/etc/bashrc \
    && (perlbrew install -j2 --64int perl-${PERLVER} \
    || (cat /opt/perlbrew/build.perl-${PERLVER}.log; exit 1;)) \
    && rm -rf /opt/perlbrew/build/* \
    && rm -rf /opt/perlbrew/dists/*

RUN source /opt/perlbrew/etc/bashrc \
    && perlbrew use ${PERLVER} \
    && perlbrew install-cpanm \
    && cpanm Carton \
    && rm -rf ~/.cpanm

ENV PATH=/opt/perlbrew/bin:/opt/perlbrew/perls/perl-${PERLVER}/bin:$PATH


##### libraries #####
FROM base AS libraries

# add additional required library and packages here:
#RUN apt-get update \
#    && apt-get -y install some-library some-package \
#    && apt-get clean && rm -rf /var/lib/apt/lists/*  # cleanup to save space

# add additional Perl modules for runtime here:
# RUN source /opt/perlbrew/etc/bashrc \
#     && perlbrew use ${PERLVER} \
#     && cpanm Some::Modules \
#     && rm -rf ~/.cpanm

##### devel #####
FROM libraries AS devel

# add additional required library and packages here:

## add locales and setup 
RUN apt-get update \
    && apt-get -y install locales \    
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen    

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# add additional Perl modules for DEVELOPMENT ONLY here:
RUN source /opt/perlbrew/etc/bashrc \
    && perlbrew use ${PERLVER} \
    && cpanm Perl::Critic Perl::Tidy \
    && rm -rf ~/.cpanm

COPY entrypoint-devel.sh /

ENTRYPOINT ["/entrypoint-devel.sh"]
CMD ["/bin/bash"]


##### runtime #####
FROM debian:buster AS rt

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
SHELL ["/bin/bash", "-c"]
ENV PERLBREW_ROOT /opt/perlbrew

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

#
# install required binary libs
#
RUN apt-get update \
    && apt-get install -y curl ca-certificates less procps lsof \
    && apt-get install -y libev4 libffi6 \
    && apt-get install -y libzmq5 libzmq3-dev \
    && apt-get install -y openssl libssl1.1 libnss3 \
    && apt-get install -y zlib1g \
    && apt-get clean && rm -rf /var/lib/apt/lists/*  # cleanup to save space

COPY --from=libraries /opt/perlbrew/ /opt/perlbrew/

COPY entrypoint.sh /

ENV PATH=/opt/perlbrew/bin:/opt/perlbrew/perls/perl-${PERLVER}/bin:$PATH
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
