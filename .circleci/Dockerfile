FROM webcenter/puppet-dev:latest

ARG PWD

RUN gem install webmock simplecov rest-client codecov

COPY ./ $PWD

WORKDIR $PWD

