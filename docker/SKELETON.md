# Example

## Initial start

```
SSH_KEY_FILE=jm-utility \
SSH_KEY_DIR=$SECRETS/utility \
AWS_DEFAULT_REGION=us-east-1 \
GITNAME="Example User" \
GITEMAIL="user@example.com" \
AWS_ACCESS_KEY_ID= \
AWS_SECRET_ACCESS_KEY= \
src/iac-k8s-bootstrap/docker/start_dev.sh
```

## Another terminal

```
docker exec -it dev01 /bin/bash
```

## Cleanup

```
docker rm dev01
```
