# Gitlab Local

Run Gitlab server and runner locally in containers and start practicing Gitlab CI/CD. The Gitlab server will run on port 80.

## Prerequisites

1. Docker and Docker Compose must be installed on your machine.
2. Make sure that no other services are running on the ports that gitlab-local will use. If you encounter a port conflict when starting your Docker containers, you can change the port mappings in the `docker-compose.yml` file or stop the conflicting services.
3. Ensure that any required environment variables are set in an `.env` file. The `.env` file should be located in the same directory as the `docker-compose.yml` file and contain values for all required environment variables. You can use the `.env.example` file as a template for the required environment variables.

## Usage

### 1. Start Gitlab and Runner
```bash
docker-compose up -d
```

### 2. Obtain Gitlab Root Password
```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

### 3. Register Runner for a Gitlab Project
To register the local runner with a specific Gitlab project, follow these steps:

1. Go to Settings -> CI/CD -> Runners in the project's repository.
2. Copy the "registration token".
3. Set an environment variable with the registration token using the following command, replacing {{registration-token}} with the actual registration token: 

```bash
export RUNNER_TOKEN={{registration token}}
```
### 4. Register the runner by running the following command:

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

## Run with Terraform Profile

To start a Minio container for the Terraform S3 Backend Configuration, run with the "terraform" profile:

### 1. Set environment variables
To set the environment variables for the Minio container, add the following lines to your `.env` file:
```text
MINIO_ROOT_USER={{access-key}}
MINIO_ROOT_PASSWORD={{secret-key}}
```
Replace `{{access-key}}` and `{{secret-key}}` with the actual values for the Minio access key and secret key, respectively. 
These are similar to Amazon S3 credentials, and Minio can be used as a local alternative to S3.

### 2. Start the Containers
To start the containers, run the following command:
```bash
docker-compose --profile terraform up -d
```

### 3. Create Bucket for a Gitlab Project
To create the S3 bucket use to store the terraform state of a gitlab project, run the following command, where `--endpoint-url` is the endpoint to the minio container and `BUCKET_NAME` for the name of the bucket.

```bash
aws --region main --endpoint-url http://localhost:9000 s3 mb s3://"$BUCKET_NAME"
```

### 4. Use with a Gitlab Project

To use the local Minio container with a Gitlab Project, use the following Terraform Backend Configuration in your project.

```
backend "s3" {
    key                          = "{{your-key}}"
    region                       = "main"
    force_path_style             = true
    skip_bucket_ssencryption     = true
    skip_bucket_accesslogging    = true
    skip_credentials_validation  = true
    skip_get_ec2_platforms       = true
    skip_metadata_api_check      = true
    skip_region_validation       = true
    skip_requesting_account_id   = true
    disable_aws_client_checksums = true
  }
```

When running `terraform init ` in your Gitlab pipeline, make sure to pass all necessary information, as the bucket name for the project, credentials and endpoint for the local minio.

You can set the required environment variables for the GitLab pipeline in the project's Gitlab repository. Go to Settings -> CI/CD -> Variables -> Add variable.
```
terraform init -backend-config="bucket=${BUCKET_NAME}" \
-backend-config="endpoint=http://localhost:9000 \
-backend-config="access_key=${MINIO_USER}" \
-backend-config="secret_key=${MINIO_PASSWORD}"
```

