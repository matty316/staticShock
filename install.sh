#!/usr/bin/env bash

swift build -c release
cd .build/release
sudo cp -f StaticShock /usr/local/bin/staticshock