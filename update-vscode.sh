#!/bin/bash
#cd /home/agcgn/Programming
#echo 'first close vscode'

#rm -r VSCode-linux-x64
#wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' -O VSCode-linux-x64.tar.gz&&tar -xzf VSCode-linux-x64.tar.gz&&rm -r VSCode-linux-x64.tar.gz

# above build has microsoft shit. no one likes that

cd /home/agcgn/Programming
git clone https://github.com/microsoft/vscode.git
cd vscode
yarn watch
