#!/usr/bin/env bash


echo "Select php version: "
read PHP_VERSION
IMAGE_NAME="alekcander/php-nginx-${PHP_VERSION}"

echo "Building docker image ${IMAGE_NAME}"
docker build --build-arg PHP_VERSION=${PHP_VERSION} -t ${IMAGE_NAME}:latest .
if [ $? -eq 0 ]; then
    #docker run --rm -it --entrypoint=/bin/ash ${IMAGE_NAME}:latest -i && exit
    docker run --rm -d -name=testing-build ${IMAGE_NAME}:latest
#    docker push alekcander/php-nginx:latest .
fi






