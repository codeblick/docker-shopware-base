#!/usr/bin/env bash
set -e

build() {
    docker build . \
        -t codeblick/shopware-base:php-${1} \
        --build-arg PHP_VERSION=${1} \
        -q
}

build 7.2
build 7.3
