#!/usr/bin/env bash

install_gem() {
    if [[ -z $(gem list "^$1$" -i) ]]; then
        echo "Installing gem $1"
        sudo gem install $1
    fi
}

install_gem bundler
bundler install
