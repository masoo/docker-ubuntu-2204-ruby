# ref. https://github.com/chef/rubydistros
FROM ubuntu:22.04

ENV RUBY_MAJOR 3.3
ARG RUBY_VERSION=3.3.1
ENV RUBY_VERSION $RUBY_VERSION
ENV PATH /opt/ruby/bin:$PATH:/opt/rbenv/plugins/ruby-build/bin

# ruby-build
RUN set -ex \
  && mkdir -p /etc/network/interfaces.d \
  && BaseDeps=' \
        git \
        gcc \
        autoconf \
        bison \
        build-essential \
        libssl-dev \
        libyaml-dev \
        libreadline6-dev \
        zlib1g-dev \
        libncurses5-dev \
        libffi-dev \
        libgdbm6 \
        libgdbm-dev \
        make \
        wget \
        curl \
        iproute2 \
        net-tools \
        tzdata \
        locales \
        ca-certificates \
  ' \
  && apt-get update \
  && DEBCONF_NOWARNINGS=yes apt-get -y upgrade \
  && DEBCONF_NOWARNINGS=yes DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $BaseDeps \
  && rm -rf /var/lib/apt/lists/* \
	&& git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build \
  && ruby-build ${RUBY_VERSION} /opt/ruby

CMD ["/bin/bash"]
