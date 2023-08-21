# postgres-gc-backup

A Docker image for performing PostgreSQL backups to Google Cloud Storage.

## Usage

### Run via Docker

```
docker run \
 -e POSTGRES_HOST=<db host> \
 -e POSTGRES_DB=<your db name> \
 -e POSTGRES_USER=<your db username> \
 -e POSTGRES_PASSWORD=<your secret> \
 -e GCS_KEY_FILE_PATH=<path to GC service account key file> \
 -e GCS_BUCKET=<GC bucket name>
 dazlabteam/postgres-gc-backup
```

### Run via Docker Compose

Edit your Docker Compose file, add new `backup` service:

```
  db:
    image: postgres:14.2
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: <your pg username>
      POSTGRES_PASSWORD: <your secret>
      POSTGRES_DB: <your db name>

  ...

  backup:
    image: dazlabteam/postgres-gc-backup
    environment:
      POSTGRES_HOST: db
      POSTGRES_DB: demo
      POSTGRES_USER: root
      POSTGRES_PASSWORD: secret
      GCS_KEY_FILE_PATH: <path to GC service account key file>
      GCS_BUCKET: <GC bucket name>
```

Then run

```
docker-compose -f <path to docker compose yaml> run --rm backup
```

or by specifying env variables via the command line:

```
docker-compose -f <path to docker compose yaml> run --rm \
 -e POSTGRES_HOST=<db host> \
 -e POSTGRES_DB=<your db name> \
 -e POSTGRES_USER=<your db username> \
 -e POSTGRES_PASSWORD=<your secret> \
 -e GCS_KEY_FILE_PATH=<path to GC service account key file> \
 -e GCS_BUCKET=<GC bucket name> \
 backup
```

### Schedule inside Kubernetes Cluster

Create Kubernetes secret containing all the environment variables:

```
kubectl create secret generic POSTGRES-gc-backup \
 --from-literal=POSTGRES_HOST=<db host> \
 --from-literal=POSTGRES_DB=<your db name> \
 --from-literal=POSTGRES_USER=<your db username> \
 --from-literal=POSTGRES_PASSWORD=<your secret> \
 --from-literal=GCS_KEY_FILE_PATH=<path to GC service account key file> \
 --from-literal=GCS_BUCKET=<GC bucket name>
```

then create CronJob using the cronjob spec file from this repo:

```
kubectl apply -f postgres-gc-backup.cronjob.yaml
```

By default, it will run every day at 00:00. To change this, edit cronjob and specify other schedule:

```
kubectl edit cronjob postgres-gc-backup
```

## License

MIT

## Links

- https://hub.docker.com/r/dazlabteam/postgres-gc-backup
- https://hub.docker.com/r/nullriver/postgres-docker-gcs-backup
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
 
