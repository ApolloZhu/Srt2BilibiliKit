#!/bin/sh
git clone https://github.com/ApolloZhu/Srt2BilibiliKit.git
cd Srt2BilibiliKit
swift package clean
swift build -c release
cp .build/release/Srt2Bilibili-cli /usr/local/bin/s2bkit
cd ..
rm -rf Srt2BilibiliKit
s2bkit
