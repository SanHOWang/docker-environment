#!/usr/bin/env bash
export MSYS_NO_PATHCONV=1
# Default values
IMAGE_NAME="aoc2026-env"
CONTAINER_NAME="aoc2026-container"
USERNAME=${USER:-$(id -un)}
MOUNT_PATHS=()

# Helper: print usage
print_usage() {
cat << EOF
    Usage: $0 {run|stop|build|rebuild|clean_container|clean_image} [options]
        run             - Run the Docker container
        stop            - Stop the Docker container if running
        build           - Build the Docker image
        rebuild         - Rebuild the Docker image without cache
        clean-container - Stop and remove the Docker container
        clean-all       - Remove the Docker image and container
        help            - usage

    Options:
        --username | -u    USERNAME                  Set the username for the container (default: current user)
        --image-name | -i  IMAGE_NAME                Set the name of the Docker image (required for run/build)
        --cont-name | -c   CONTAINER_NAME            Set the name of the Docker container (required for run)
        --mount | -m       HOST_PATH:CONTAINER_PATH  Mount a host directory into the container (can be used multiple times)
EOF

}

# Build Docker image
build_image() {
    local nocache="$1"
    [[ -z ${IMAGE_NAME} ]] && { echo "IMAGE_NAME is not set"; exit 1; }

    if docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
        echo "Image '$IMAGE_NAME' already exists."
        echo "Use './docker.sh rebuild' to force rebuild."
    else
        echo "Building Docker image '$IMAGE_NAME'..."
        docker build \
        ${nocache:+--no-cache} \
        --build-arg UID=$(id -u) \
        --build-arg GID=$(id -g) \
        --build-arg USERNAME="$USERNAME" \
        -t "$IMAGE_NAME" .
    fi
}

# Run Docker container
run_container() {
    [[ -z ${CONTAINER_NAME} ]] && { echo "CONTAINER_NAME is not set"; exit 1; }

    # Default mount if none is specified
    if [[ ${#MOUNT_PATHS[@]} -eq 0 ]]; then
        HOST_DEFAULT="./workspace"
        CTR_DEFAULT="/home/${USERNAME}/workspace"
        mkdir -p "$HOST_DEFAULT"
        MOUNT_PATHS+=("${HOST_DEFAULT}:${CTR_DEFAULT}")
    fi

    # 解析 mount 指令
    local vols=()
    for m in "${MOUNT_PATHS[@]}"; do
        IFS=':' read -r host ctr <<< "$m"
        ctr=${ctr:-"/home/${USERNAME}/workspace"}  # 如果沒有 container path，使用預設
        mkdir -p "$host"
        vols+=("-v" "$host:$ctr")
    done

    # 檢查容器狀態
    local status
    status=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "absent")

    case "$status" in
        running)
            echo "Container '$CONTAINER_NAME' is already running. Attaching..."
            docker exec -it "$CONTAINER_NAME" /bin/bash
            ;;
        exited)
            echo "Starting existing container '$CONTAINER_NAME'..."
            docker start "$CONTAINER_NAME"
            docker exec -it "$CONTAINER_NAME" /bin/bash
            ;;
        *)
            echo "Creating and running new container '$CONTAINER_NAME'..."
            docker run -it -d \
                -e USERID="$(id -u)" \
                -e GROUPID="$(id -g)" \
                -p 8888:8888 \
                "${vols[@]}" \
                --hostname "$(echo "$CONTAINER_NAME" | tr '[:lower:]' '[:upper:]')" \
                --name "$CONTAINER_NAME" \
                "$IMAGE_NAME"
            docker exec -it "$CONTAINER_NAME" /bin/bash
            ;;
    esac
}

stop_container() {
    docker stop  "${CONTAINER_NAME}" 2>/dev/null || true;
}

# Clean container only
clean_container() {
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    echo "Removed container '$CONTAINER_NAME'."
}

# Clean image only
clean_image() {
    docker rmi -f "$IMAGE_NAME" 2>/dev/null || true
    echo "Removed image '$IMAGE_NAME'."
}


# Parse CLI arguments
ACTION=$1
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--username)
        [[ -z $2 || $2 == --* ]] && { echo "--username requires value"; exit 1; }
            USERNAME="$2"
            shift 2
            ;;
        -i|--image-name)
        [[ -z $2 || $2 == --* ]] && { echo "--image-name requires value"; exit 1; }
            IMAGE_NAME="$2"
            shift 2
            ;;
        -c|--cont-name)
        [[ -z $2 || $2 == --* ]] && { echo "--cont-name requires value"; exit 1; }
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -m|--mount)
        [[ -z $2 || $2 == --* ]] && { echo "--mount requires value"; exit 1; }
            MOUNT_PATHS+=("$2")
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1;
            ;;
    esac
done

case "$ACTION" in
    build)
        build_image
        exit 0
        ;;
    run)
        run_container
        exit 0
        ;;
    stop)
        stop_container;
        exit 0
        ;;

    clean-all)
        clean_container
        clean_image
        exit 0
        ;;
    clean-container)
        clean_container
        exit 0
        ;;
    rebuild)
        clean_container
        clean_image
        build_image nocache
        exit 0
        ;;
    help|--help|-h)
        print_usage
        exit 0
        ;;
    *)
        echo "Unknown action: $ACTION"
        print_usage
        exit 0
        ;;
esac
