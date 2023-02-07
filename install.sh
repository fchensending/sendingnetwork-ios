#!/bin/bash

curl --noproxy '*'  http://10.1.1.241/Gobind.xcframework.tar.gz -L -O -J
tar -xzvf Gobind.xcframework.tar.gz
rm Gobind.xcframework.tar.gz
