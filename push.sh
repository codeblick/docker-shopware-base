#!/usr/bin/env bash
set -e

push() {
    docker push codeblick/shopware-base:php-${1}
}

docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}

push 7.2
push 7.3
