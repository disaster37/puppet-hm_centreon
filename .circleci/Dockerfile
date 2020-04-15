FROM webcenter/puppet-dev:latest

ARG http_proxy
ARG https_proxy
ARG PWD

RUN gem install webmock simplecov rest-client codecov

COPY ./ $PWD

WORKDIR $PWD

