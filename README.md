# Srt2BilibiliKit

[![GPLv3 License](https://img.shields.io/github/license/ApolloZhu/Srt2BilibiliKit.svg)](LICENSE)

A swift solution for uploading SubRip file as danmaku to Bilibili. 

Inspired by [srt2bilibili](https://github.com/cnbeining/srt2bilibili) by [@cnbeining](https://github.com/cnbeining) under [GPLv2 License](https://github.com/cnbeining/srt2bilibili/blob/fake-ip/LICENSE) and [bilibili-mac-client](https://github.com/typcn/bilibili-mac-client) by [@typcn](https://github.com/typcn) under [GPLv3 License](https://github.com/typcn/bilibili-mac-client/blob/master/LICENSE).

## S2BCookie

Requirement for sending danmaku, consists of `DedeUserID`, `DedeUserID__ckMd5`, and `SESSDATA`. Default to a file named `bilicookies` at current working directory, which can be retrieved using [biliupload/getcookie.py](https://github.com/dantmnf/biliupload/blob/master/getcookie.py) by [@dantmnf](https://github.com/dantmnf).
