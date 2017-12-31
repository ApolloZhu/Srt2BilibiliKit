# Srt2BilibiliKit

[![GitHub (pre-)release](https://img.shields.io/github/release/ApolloZhu/Srt2BilibiliKit/all.svg)](https://github.com/ApolloZhu/Srt2BilibiliKit/releases) [![Build Status](https://travis-ci.org/ApolloZhu/Srt2BilibiliKit.svg?branch=master)](https://travis-ci.org/ApolloZhu/Srt2BilibiliKit) [![Swift 4.0](https://img.shields.io/badge/Swift-4.0-ffac45.svg)](https://developer.apple.com/swift/) [![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/) [![GPLv3 License](https://img.shields.io/github/license/ApolloZhu/Srt2BilibiliKit.svg)](https://github.com/ApolloZhu/Srt2BilibiliKit/blob/master/LICENSE) [![Documentation](https://apollozhu.github.io/Srt2BilibiliKit/badge.svg)](https://apollozhu.github.io/Srt2BilibiliKit) [![codecov](https://codecov.io/gh/ApolloZhu/Srt2BilibiliKit/branch/master/graph/badge.svg)](https://codecov.io/gh/ApolloZhu/Srt2BilibiliKit)

[English Introduction](./README_EN.md)

把 `.srt` 字幕文件作为弹幕发到 bilibili 的命令行程序。

## 安装

因为本程序是通过 Swift 语言实现的，所以您需要先安装

- macOS: [![从 Mac App Store 免费下载正版 Xcode](https://developer.apple.com/app-store/marketing/guidelines/mac/images/badge-download-on-the-mac-app-store.svg)](https://itunes.apple.com/app/id497799835)
- Windows 10: 参考 [在 Windows 10 上跑 Swift](https://apollozhu.github.io/2017/09/22/swift-on-win-10/) 或 [B 站 cv18127](https://www.bilibili.com/read/mobile/18127)
- Ubuntu: `eval "$(curl -sL https://raw.githubusercontent.com/ApolloZhu/script/master/swift/install/4)"`

完成之后在命令行/终端里输入一下命令来下载并安装本程序到 `/usr/local/bin`：

```bash
eval "$(curl -sL https://raw.githubusercontent.com/ApolloZhu/Srt2BilibiliKit/master/sh/install-cmd)"
```

安装完成后程序会自动显示使用方法。

## 隐私政策

本程序采用扫码的方式登录 B 站，不需要您提供账号和密码。但标示您身份信息的 [Cookie](https://baike.baidu.com/item/cookie/1119) 会且只会被明文保存到 `bilicookies` 文件和与弹幕一起发送给 B 站。 ***请避免分享此文件给其他人。*** 因使用本程序造成的一切后果，本程序开发者和其他贡献人员概不负责。
