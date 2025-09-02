```
SSH_KEY_FILE=jm-utility \
SSH_KEY_DIR=$SECRETS/utility \
AWS_DEFAULT_REGION=us-east-1 \
AWS_ACCESS_KEY_ID=PLACEHOLDER \
AWS_SECRET_ACCESS_KEY=PLACEHOLDER \
src/iac-k8s-bootstrap/docker/start_dev.sh
```

```
docker exec -it dev01 /bin/bash
```
