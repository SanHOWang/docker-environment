#!/bin/bash

# Default values
IMAGE_NAME="aoc2026-env"
CONTAINER_NAME="aoc2026-container"
USERNAME=${USER:-user}
HOSTNAME="aoc2026-host"
MOUNT_PATHS=()

# Helper: print usage
print_usage() {
    echo "Usage:"
    echo "  ./docker.sh build"
    echo "  ./docker.sh run [--username USER] [--image-name NAME] [--cont-name NAME] [--hostname NAME] [--mount PATH]..."
    echo "  ./docker.sh clean"
    echo "  ./docker.sh rebuild"
    exit 1
}

# Build Docker image
build_image() {
    if docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
        echo "Image '$IMAGE_NAME' already exists."
        echo "Use './docker.sh rebuild' to force rebuild."
    else
        echo "Building Docker image '$IMAGE_NAME'..."
        echo "Using UID=$(id -u), GID=$(id -g), USERNAME=$USERNAME"
        docker build \
            --build-arg UID=$(id -u) \
            --build-arg GID=$(id -g) \
            --build-arg USERNAME="$USERNAME" \
            -t "$IMAGE_NAME" .
    fi
}

# Run Docker container
run_container() {
    local status=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)

    DOCKER_RUN_CMD="docker run -it --hostname $HOSTNAME"

    # Add mounts
    for path in "${MOUNT_PATHS[@]}"; do
        DOCKER_RUN_CMD+=" -v ${path}:${path}"
    done

    DOCKER_RUN_CMD+=" --name $CONTAINER_NAME $IMAGE_NAME"

    if [ "$status" = "running" ]; then
        echo "Container '$CONTAINER_NAME' is already running. Attaching..."
        docker exec -it "$CONTAINER_NAME" bash
    elif [ "$status" = "exited" ]; then
        echo "Starting existing container '$CONTAINER_NAME'..."
        docker start "$CONTAINER_NAME"
        docker exec -it "$CONTAINER_NAME" bash
    else
        echo "Creating and running new container '$CONTAINER_NAME'..."
        eval "$DOCKER_RUN_CMD"
    fi
}

# Clean Docker image and container
clean_all() {
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    docker rmi -f "$IMAGE_NAME" 2>/dev/null || true
    echo "Cleaned up image and container."
}

# Parse CLI arguments
ACTION=$1
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --username)
            USERNAME="$2"
            shift 2
            ;;
        --image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --cont-name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        --mount)
            MOUNT_PATHS+=("$2")
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            ;;
    esac
done

case "$ACTION" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    clean)
        clean_all
        ;;
    rebuild)
        clean_all
        build_image
        ;;
    *)
        print_usage
        ;;
esac
