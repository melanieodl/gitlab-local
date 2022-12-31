docker-compose exec gitlab-runner gitlab-runner register \
    --non-interactive \
    --url http://gitlab/ --clone-url http://gitlab/ \
    --description "local" \
    --docker-image "docker:20.10.16" \
    --registration-token "$RUNNER_TOKEN" \
    --executor "docker" \
    --docker-privileged \
    --docker-network-mode gitlab-local_gitlab