# ref. https://github.com/chef/rubydistros
FROM ubuntu:22.04 AS base

ENV PATH=/opt/ruby/bin:$PATH

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
        rustc \
  ' \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $BaseDeps \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /opt/ruby

# Stage for ruby-build (cached independently from CACHE_BUST)
FROM base AS ruby-build-base
RUN set -ex \
  && mkdir -p /opt/rbenv/plugins \
	&& git clone --depth 1 https://github.com/rbenv/ruby-build.git /opt/rbenv/plugins/ruby-build

# Stage with cache buster (does not affect ruby-build layer)
FROM ruby-build-base AS base2
ARG CACHE_BUST=default
RUN set -ex \
  && echo "Cache bust: $CACHE_BUST"

FROM base2 AS builder
ARG RUBY_VERSION=4.0.0
ENV RUBY_VERSION=${RUBY_VERSION}
ENV PATH=/opt/rbenv/plugins/ruby-build/bin:$PATH
RUN set -ex \
  && ruby-build ${RUBY_VERSION} /opt/ruby

FROM base AS final
COPY --from=builder /opt/ruby /opt/ruby
ARG RUBY_VERSION=4.0.0
ENV RUBY_VERSION=${RUBY_VERSION}

LABEL maintainer="masoo" \
      version="1.0" \
      description="Ruby development environment on Ubuntu 22.04" \
      ruby.version="${RUBY_VERSION}"

CMD ["/bin/bash"]
