#!/bin/bash

# Start CloudSQL Proxy Docker Container for multiple instances
start_cloud_sql_proxy() {
    docker rm -f CloudSQLProxy 2>/dev/null
    docker run -d --name CloudSQLProxy \
        -v $HOME/.config/gcloud/application_default_credentials.json:/path/to/service-account-key.json \
        -p 127.0.0.1:2001-2005:2001-2005 \
        -p 127.0.0.1:2101-2105:2101-2105 \
        --restart unless-stopped \
        gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.1 \
        --address 0.0.0.0 \
        -c /path/to/service-account-key.json \
        "bird-nest-dev:europe-north1:services-db-instance?port=2001" \
        "bird-nest-test:europe-north1:services-db-instance?port=2002" \
        "bird-nest-stage:europe-north1:services-db-instance?port=2003" \
        "bird-nest-prod:europe-north1:services-db-instance?port=2004" \
        "bird-nest-prod:europe-north1:services-db-instance-replica?port=2005" \
        "bird-nest-dev:europe-north1:status-db-instance?port=2101" \
        "bird-nest-test:europe-north1:status-db-instance?port=2102" \
        "bird-nest-stage:europe-north1:status-db-instance?port=2103" \
        "bird-nest-prod:europe-north1:status-db-instance?port=2104" \
        -i
}

# Restart Spotify Daemon Docker Container and open Spotify-TUI
restart_spotifyd() {
    brew services restart spotifyd && spt
}

# Check the status of running Docker containers
check_docker_containers() {
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Stop and remove a Docker container by name
docker_remove_container() {
    if [[ -z "$1" ]]; then
        echo "Usage: docker_remove_container <container_name>"
        return 1
    fi

    local container_name=$1
    docker stop "$container_name" && docker rm "$container_name"
}

# Quickly log into a running Docker container
docker_exec() {
    if [[ -z "$1" ]]; then
        echo "Usage: docker_exec <container_name>"
        return 1
    fi

    local container_name=$1
    docker exec -it "$container_name" /bin/bash
}

# Prune all unused Docker resources (containers, images, volumes, etc.)
docker_prune_all() {
    echo "Pruning all unused Docker resources..."
    docker system prune -a --volumes
}

# Build and run a Docker Compose stack
docker_compose_up() {
    if [[ -z "$1" ]]; then
        echo "Usage: docker_compose_up <path_to_docker_compose_file>"
        return 1
    fi

    local compose_file=$1
    docker-compose -f "$compose_file" up -d
}

# Bring down a Docker Compose stack
docker_compose_down() {
    if [[ -z "$1" ]]; then
        echo "Usage: docker_compose_down <path_to_docker_compose_file>"
        return 1
    fi

    local compose_file=$1
    docker-compose -f "$compose_file" down
}
