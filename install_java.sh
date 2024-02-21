#!/bin/bash

path=/opt/java/
cd $path

wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz


tar -xvf jdk-17_linux-x64_bin.tar.gz
cd jdk-17.0.10

export PATH=$PATH:/${path}jdk-17.0.10/bin
