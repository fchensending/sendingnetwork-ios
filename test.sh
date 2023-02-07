#!/bin/sh

set -e
set -x

pod install
#xcodebuild -workspace SendingnetworkSDK.xcworkspace/ -scheme SendingnetworkSDK -sdk iphonesimulator analyze

git -C synapse pull || git clone https://github.com/sending-network/synapse
[ -d venv ] || virtualenv venv
. venv/bin/activate

#pip install --process-dependency-links synapse/
#python synapse/synapse/python_dependencies.py | xargs -n1 pip install

pip install --upgrade pip
pip install --upgrade --process-dependency-links https://github.com/sending-network/synapse/tarball/master

basedir=`pwd`
function cleanup {
    echo `date "+%F %T"` - clean up
    cd $basedir
    cd synapse/demo
    ./stop.sh
}
trap cleanup EXIT

cd synapse/demo
./stop.sh || true
./clean.sh
./start.sh --no-rate-limit

echo `date "+%F %T"` - start xcode
cd ../..
xcodebuild -workspace SendingnetworkSDK.xcworkspace/ -scheme SendingnetworkSDK -sdk iphonesimulator  -destination 'name=iPhone 5s' test 2>&1 | ocunit2junit
echo `date "+%F %T"` - xcode ended
