# Gitlab Local

## Run Gitlab and Runner
```bash
docker-compose up -d
```

## Run with Terraform Profile
This will start the S3 Container for Terraform Backend configurations
```
docker-compose --profile terraform up -d
```

## Get Gitlab Root Password
```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

## Register Runner
```bash
docker-compose exec gitlab-runner gitlab-runner register \
    --non-interactive \
    --url http://gitlab/ --clone-url http://gitlab/ \
    --description "local" \
    --docker-image "docker:20.10.16" \
    --registration-token "$RUNNER_TOKEN" \
    --executor "docker" \
    --docker-privileged \
    --docker-network-mode gitlab-local_gitlab
```

## Local S3 for Terraform Backend
### Export Environment Variables 
```bash
export BUCKET_NAME=microservices-aws-tf; \
export AWS_ACCESS_KEY_ID=gitlab; \
export AWS_SECRET_ACCESS_KEY=secret_key
```

### Create Bucket
```bash
aws --region main --endpoint-url http://localhost:9000 s3 mb s3://"$BUCKET_NAME"
```

