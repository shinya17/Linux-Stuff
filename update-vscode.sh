#!/bin/bash
cd /home/agcgn/Programming
echo 'first close vscode'

rm -r VSCode-linux-x64
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' -O VSCode-linux-x64.tar.gz&&tar -xzf VSCode-linux-x64.tar.gz&&rm -r VSCode-linux-x64.tar.gz
