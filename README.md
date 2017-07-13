# Srt2BilibiliKit

[![GitHub (pre-)release](https://img.shields.io/github/release/ApolloZhu/Srt2BilibiliKit/all.svg)](https://github.com/ApolloZhu/Srt2BilibiliKit/releases) [![Swift 4.0](https://img.shields.io/badge/Swift-4.0-ffac45.svg)](https://developer.apple.com/swift/) [![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/) [![GPLv3 License](https://img.shields.io/github/license/ApolloZhu/Srt2BilibiliKit.svg)](https://github.com/ApolloZhu/Srt2BilibiliKit/blob/master/LICENSE) [![Documentation Coverage](https://raw.githubusercontent.com/ApolloZhu/Srt2BilibiliKit/master/docs/badge.svg)](https://apollozhu.github.io/Srt2BilibiliKit)

A swift solution for uploading SubRip file as danmaku to Bilibili. 

Inspired by [srt2bilibili](https://github.com/cnbeining/srt2bilibili) by [@cnbeining](https://github.com/cnbeining) under [GPLv2 License](https://github.com/cnbeining/srt2bilibili/blob/fake-ip/LICENSE) and [bilibili-mac-client](https://github.com/typcn/bilibili-mac-client) by [@typcn](https://github.com/typcn) under [GPLv3 License](https://github.com/typcn/bilibili-mac-client/blob/master/LICENSE).

## Getting the Cookie

Bilibili kept their cookies after you login, and we need those cookies named `DedeUserID`, `DedeUserID__ckMd5`, and `SESSDATA` to send your danmaku. You should use [biliupload/getcookie.py](https://github.com/dantmnf/biliupload/blob/master/getcookie.py) by [@dantmnf](https://github.com/dantmnf) to pack them in a file  named `bilicookies`, and save it under current working directory.

## Command Line Interface

To install the command line tool, you either needs the latest Xcode, or both the Swift Package Manager and the Swift compiler installed.

Copy and paste the following code to your favorite terminal app,  Srt2BilibiliKit will compile and install to `/usr/local/bin`

```bash
eval "$(curl -sL https://raw.githubusercontent.com/ApolloZhu/Srt2BilibiliKit/master/install-cmd.sh)"
```
