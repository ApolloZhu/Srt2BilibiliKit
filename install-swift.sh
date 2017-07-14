#!/usr/bin/env bash
# Modified based on github.com/onevcat/Swift-CI
# (which was stolen from vapor).

VERSION="4.0"
DATE="2017-07-11"

echo "Swift $VERSION ($DATE) Development Snapshot Installation";

# Determine OS
UNAME=`uname`;
if [[ $UNAME == "Darwin" ]];
then
    OS="macOS";
else
    if [[ $UNAME == "Linux" ]];
    then
        UBUNTU_RELEASE=`lsb_release -a 2>/dev/null`;
        if [[ $UBUNTU_RELEASE == *"16.10"* ]]; then
            OS="ubuntu1610";
        elif [[ $UBUNTU_RELEASE == *"16.04"* ]]; then
            OS="ubuntu1604";
        else
            OS="ubuntu1404";
        fi
    else
        echo "Unsupported Operating System: $UNAME";
    fi
fi
echo "🖥  Operating System: $OS";

if [[ $OS != "macOS" ]];
then
    echo "📚 Installing Dependencies"
    sudo apt-get install -y clang libicu-dev

    echo "🐦 Installing Swift";
    PREFIX="swift-$VERSION-DEVELOPMENT-SNAPSHOT-$DATE-a"
    if [[ $OS == "ubuntu1610" ]]; then
        SWIFTFILE="$PREFIX-ubuntu16.10";
    elif [[ $OS == "ubuntu1604" ]]; then
        SWIFTFILE="$PREFIX-ubuntu16.04";
    else
        SWIFTFILE="$PREFIX-ubuntu14.04";
    fi
    wget https://swift.org/builds/swift-$VERSION-branch/$OS/$PREFIX/$SWIFTFILE.tar.gz
    tar -zxf $SWIFTFILE.tar.gz
    export PATH=$PWD/$SWIFTFILE/usr/bin:"${PATH}"
fi

echo "📅 Version: `swift --version`";