FROM webcenter/puppet-dev:latest

ARG http_proxy
ARG https_proxy

RUN gem install webmock simplecov rest-client

COPY ./ /project/

WORKDIR /project

