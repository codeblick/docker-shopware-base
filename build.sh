#!/usr/bin/env bash
set -e

build() {
    docker build . \
        -t codeblick/shopware-base:php-${2} \
        --build-arg PHP_VERSION=${1} \
        --build-arg WITH_GRUNT=${3} \
        -q
}

build 7.2 7.2 0
build 7.3 7.3 0
build 7.2 7.2-dev 1
build 7.3 7.3-dev 1
