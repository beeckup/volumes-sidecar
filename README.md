# Sidecar Backup Volumes

Example deploy on  ```deploy_sidecar_example/docker-compose.yml```

Copy `env.sample` as `.env`

Automatically create tar.gz of `FOLDERS` based on `SCHEDULE`

ENVIROMENT VARIABLE   | DESCRIPTION | Values
----------   | ---------- | --------------  
FOLDERS | folders comma separated | example `/var/www,/var/etc`
SCHEDULE | see below | 

## Schedule

Tip on ```SCHEDULE``` enviroment variable:

Field name   | Mandatory? | Allowed values  | Allowed special characters
----------   | ---------- | --------------  | --------------------------
Seconds      | Yes        | 0-59            | * / , -
Minutes      | Yes        | 0-59            | * / , -
Hours        | Yes        | 0-23            | * / , -
Day of month | Yes        | 1-31            | * / , - ?
Month        | Yes        | 1-12 or JAN-DEC | * / , -
Day of week  | Yes        | 0-6 or SUN-SAT  | * / , - ?



## Minio/S3 config

ENVIROMENT VARIABLE   | DESCRIPTION | Values
----------   | ---------- | --------------  
S3_UPLOAD | Flag to enable s3 upload | `true` or empty
S3_BUCKET | Bucket name | string
S3_HOST | host:port | `host:port`
S3_PROTOCOL | protocol type | `http` or `https`
S3_KEY | key | string
S3_SECRET | secret | string
MINIO_PORT | local minio port to expose on host | port number

# Usage

Create `.env` file:

```bash
### db connection
FOLDERS=/var/www
SCHEDULE=0 * * * * *

### PUT S3_UPLOAD to true to upload your dump on s3 or minio bucket
S3_UPLOAD=true
### S3 or minio host
S3_HOST=minio:9000
### Protocol
S3_PROTOCOL=http
### Your bucket name
S3_BUCKET=cicciopollo
### minio or s3 credentials
S3_KEY=85A8U57ZITLSLFBYKNCG
S3_SECRET=14MAuAetrv7y3E6zAuUOimXy5KYRqrZKw3cWuEe/
### port of local minio
MINIO_PORT=9000

```

Create `docker-compose.yml` file:

```yml
version: '2'
services:
  sidecar-backup-mysql:
      image: nutellinoit/sidecar-backup-volumes:1.1
      volumes:
          - ./dumpdata:/go/src/app/dumpdata # Local temp repository
      restart: always
      environment:
        - FOLDERS=${FOLDERS}
        - SCHEDULE=${SCHEDULE}
        - S3_UPLOAD=${S3_UPLOAD}
        - S3_BUCKET=${S3_BUCKET}
        - S3_KEY=${S3_KEY}
        - S3_SECRET=${S3_SECRET}
        - S3_HOST=${S3_HOST}
        - S3_PROTOCOL=${S3_PROTOCOL}
      volumes_from:
        - wordpress:ro  # example mounted volumes for backups
###################
##### example wordpress install to backup
  wordpress:
      image: wordpress
      restart: always
      ports:
        - "80:80"
      volumes:
        - ./wp-app:/var/www/html

```

Launch with

```bash
docker-compose up -d
```
