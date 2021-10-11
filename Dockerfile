FROM google/cloud-sdk:alpine

RUN apk add --update --no-cache \
  postgresql-client \
  curl \
  python3 \
  py-pip \
  py-cffi \
  && pip install --upgrade pip \
  && apk add --virtual build-deps \
  gcc \
  libffi-dev \
  python3-dev \
  linux-headers \
  musl-dev \
  openssl-dev \
  cargo \
  && apk del build-deps \
  && rm -rf /var/cache/apk/*

ADD ./run.sh /postgres-gc-backup/run.sh
WORKDIR /postgres-gc-backup/

RUN chmod +x /postgres-gc-backup/run.sh

CMD ["/postgres-gc-backup/run.sh"]