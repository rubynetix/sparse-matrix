#!/usr/bin/env bash

install_gem() {
    if [[ -z $(gem list "^$1$" -i) ]]; then
        echo "Installing gem $1"
        sudo gem install $1
    fi
}

gem update --system
gem install bundler
bundler install
