#!/usr/bin/env bash
set -e

push() {
    docker push codeblick/shopware-base:php-${1}
}

# push 7.2
# push 7.3
push 7.4
# push 7.2-dev
# push 7.3-dev
push 7.4-dev
