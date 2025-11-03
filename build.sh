#!/bin/bash
# clear

banner() {
    echo ""
    echo "  _           _ _     _       _     "
    echo " | |__  _   _(_) | __| |  ___| |__  "
    echo " | '_ \| | | | | |/ _  | / __|  _ \ "
    echo " | |_) | |_| | | | (_| |_\__ \ | | |"
    echo " |_.__/ \__,_|_|_|\__,_(_)___/_| |_|"
    echo ""
}

# Define the usage function
usage() {
    local custom_message="$1"
    if [ -n "$custom_message" ]; then
        echo "$custom_message"
        echo ""
    fi
    echo "Usage: build.sh [OPTIONS] <image_type>"
    echo ""
    echo "Options:"
    echo "  -h, --help               Print this message"
    echo "  -v, --version            Print version"
    echo ""
    echo "Image Types:"
    echo "  latest                   Latest image."
    echo "  slim                     Slim image."
    echo ""
    exit 1
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            banner
            usage
            ;;
        -v|--version)
            echo "build.sh version 1.0.0"
            exit 0
            ;;
        *)
            break # Exit the option parsing loop if an argument is not an option
            ;;
    esac
done

# Check if the script was called with arguments
if [ $# -eq 0 ]; then
    banner
    usage
fi

banner
# Check for the image type
case "$1" in
    latest)
        docker buildx build -t codjix/oracle-apex:latest -f ./Dockerfile .
        ;;
    slim)
        docker buildx build -t codjix/oracle-apex:slim -f ./slim.Dockerfile .
        ;;
    *)
        # Invalid image type
        usage "Invalid option or image type: $1"
        exit 1
        ;;
esac