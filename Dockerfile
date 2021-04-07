FROM alpine:3.13
RUN apk add --no-cache make ruby-full ruby-dev build-base zlib zlib-dev aws-cli && \
    apk add --no-cache libreoffice py3-pip && \
    pip install unoconv && \
    gem install roo --version 2.8.3
VOLUME /volume
WORKDIR /volume
ENTRYPOINT sh
