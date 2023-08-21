#! /bin/sh

set -e
set -o errexit # stop script immediately on error
set -o pipefail # enable strict command pipe error detection

if [ "${GCS_KEY_FILE_PATH}" = "" ]; then
  echo "You need to set the GCS_KEY_FILE_PATH	environment variable."
  exit 1
fi

if [ "${GCS_BUCKET}" = "" ]; then
  echo "You need to set the GCS_BUCKET environment variable."
  exit 1
fi

if [ "${POSTGRES_DATABASE}" = "" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_PORT}" = "" ]; then
  POSTGRES_PORT=5432
fi

if [ "${POSTGRES_HOST}" = "" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

echo "Creating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."

DATE=$(date -u "+%F-%H%M%S")
ARCHIVE_NAME="${POSTGRES_DATABASE}-${DATE}-$DATE.sql.gz"

export PGPASSWORD=$POSTGRES_PASSWORD
# shellcheck disable=SC2086
pg_dump -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" $POSTGRES_DATABASE $POSTGRES_EXTRA_OPTS | gzip >${ARCHIVE_NAME}

echo "Uploading dump to ${GCS_BUCKET}"

gcloud auth activate-service-account --key-file="${GCS_KEY_FILE_PATH}"
gsutil cp "${ARCHIVE_NAME}" "gs://$GCS_BUCKET"

rm "${ARCHIVE_NAME}"

echo "Backup done!"
