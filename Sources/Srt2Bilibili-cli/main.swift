//
//  main.swift
//  Srt2BilibiliKit-cli
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation
import BilibiliKit
import Srt2BilibiliKit
import swift_qrcodejs

// MARK: Arguments

var arguments: [String]
arguments = CommandLine.arguments

// MARK: Usage/Help

let usage = """
usage: s2bkit [-h] -a avNumber -s subRipFile [-p 1] [-c ./bilicookies] [-o \(S2BDanmaku.Config.default.color)...] [-f \(S2BDanmaku.Config.default.fontSize.rawValue)...] [-m \(S2BDanmaku.Config.default.mode.rawValue)...] [-l \(S2BDanmaku.Config.default.pool.rawValue)...] [-w \(S2BEmitter.defaultDelay)]
"""

let help = """
-h (optional)
\tPrint the usage

-a aid (required)
\tThe av number to post to

-s srt (required)
\tThe srt file you to post.

-p page (default 1)
\tThe page/part number.

-c cookie (default ./bilicookies)
\tThe path to the cookie file, requirement for posting danmaku.
\tWe can generate for you, or you can create one from browser cookies.
\tIts structure is similar to
\t
\tDedeUserID=xx;DedeUserID__ckMd5=xx;SESSDATA=xx

-o color (default \(S2BDanmaku.Config.default.color))
\tThe color of danmaku, represented in dec(\(S2BDanmaku.Config.default.color)) or hex(0x\(String(format: "%x", S2BDanmaku.Config.default.color))).

-f fontSize (default \(S2BDanmaku.Config.default.fontSize.rawValue))
\tThe font size of danmaku.

-m mode (default \(S2BDanmaku.Config.default.mode.rawValue))
\tThe mode of danmaku.
\t1: Normal
\t4: Bottom
\t5: Top
\t6: Reversed
\t7: Special
\t9: Advanced

-l pool (default \(S2BDanmaku.Config.default.pool.rawValue))
\tThe Danmaku Pool to use.
\t0: Normal
\t1: Subtitle (Suggested if you own the video)
\t2: Special

-w delay (default \(S2BEmitter.defaultDelay))
\tCool time in seconds (time to wait before posting the next one).
\tNumber smaller than the default may result in ban or failure.

"""

func exitAfterPrintingHelp() -> Never { print(usage);exit(0) }
func exitAfterPrintingUsage() -> Never { print(usage+"\n"+help);exit(0) }

// MARK: Parse Arguments

var aid: Int?
var srt: String?
var page = 1
var cookiePath: String? = nil
var color = [Int]()
var fontSize = [Int]()
var mode = [Int]()
var pool = [Int]()
var delay = S2BEmitter.defaultDelay

guard arguments.count > 1 else { exitAfterPrintingHelp() }
var index = 1

func hasNext() -> Bool {
    return index < arguments.count && !arguments[index].hasPrefix("-")
}

func next() -> String {
    defer { index += 1 }
    return arguments[index]
}

while index < arguments.count {
    let cur = arguments[index].lowercased()
    index += 1
    if ["-h", "-?", "--help"].contains(cur) { exitAfterPrintingUsage() }
    if index == arguments.count { break }
    if !hasNext() { continue }
    switch cur {
    case "-a", "--av", "--aid":
        aid = Int(next())
    case "-s", "--srt", "--subrip":
        srt = next()
    case "-p", "--page", "--part":
        page = Int(next()) ?? page
    case "-c", "--cookie":
        cookiePath = next()
    case "-o", "--color":
        while hasNext() {
            var option = next()
            if option.hasPrefix("0x") { option.removeFirst(2) }
            color.append(Int(option) ?? Int(option, radix: 16)
                ?? S2BDanmaku.Config.default.color)
        }
    case "-f", "--font", "--size", "--fontsize":
        while hasNext() {
            fontSize.append(Int(next()) ?? S2BDanmaku.Config.default.fontSize.rawValue)
        }
    case "-m", "--mode":
        while hasNext() {
            mode.append(Int(next()) ?? S2BDanmaku.Config.default.mode.rawValue)
        }
    case "-l", "--pool":
        while hasNext() {
            pool.append(Int(next()) ?? S2BDanmaku.Config.default.pool.rawValue)
        }
    case "-w", "--cooltime", "--delay":
        delay = Double(next()) ?? delay
    default:
        break
    }
}

guard let cookie = BKCookie(path: cookiePath) else {
    var didPromptForConfirmation = true
    func stateHandler(_ state: BKLoginHelper.LoginState) {
        switch state {
        case .started: return
        case .needsConfirmation:
            if !didPromptForConfirmation { return }
            print("请点击网页/设备上的「确认登录」")
            
            didPromptForConfirmation = false
        case .succeeded(cookie: let newCookie):
            newCookie.save()
            print("已经保存登录信息，请重新尝试上传弹幕")
            exit(0)
        case .expired, .missingOAuthKey:
            fatalError("等待时间过长，请重新尝试登录")
        case .unknown(status: let status):
            exit(Int32(status))
        case .errored:
            fatalError("遇到非 Bilibili 造成的错误")
        }
    }
    
    BKLoginHelper.default.login(handleLoginInfo: { url in
        if let qr = QRCode(url.url) {
            let inverse = "\u{1B}[7m  ", normal = "\u{1B}[0m  "
            print(qr.toString(filledWith: inverse, patchedWith: normal))
            print("用 B 站客户端扫描二维码", terminator: "，或")
        }
        print("在登录了 B 站账号的浏览器打开网页：\(url.url)")
    }, handleLoginState: stateHandler)
    RunLoop.current.run()
    exit(0)
}

// MARK: Check Required
guard let aid = aid else { fatalError("必须提供 AV 号") }
guard let path = srt, var subRip = S2BSubRipFile(path: path) else { fatalError("必须提供 srt 文件的路径") }

// MARK: Default Configs

if color.count == 0 { color = [S2BDanmaku.Config.default.color] }
if fontSize.count == 0 { fontSize = [S2BDanmaku.Config.default.fontSize.rawValue] }
if mode.count == 0 { mode = [S2BDanmaku.Config.default.mode.rawValue] }
if pool.count == 0 { pool = [S2BDanmaku.Config.default.pool.rawValue] }

// MARK: Zip Configs

/// Find the greatest common divisor
///
/// - Parameters:
///   - m: a number
///   - n: another number
/// - Returns: greatest common divisor of `m` and `n`
func gcd(_ m: Int, _ n: Int) -> Int { return n == 0 ? m : gcd(n, m % n) }

/// Find the least common multiple
///
/// - Parameters:
///   - m: a number
///   - n: another number
/// - Returns: least common multiple of `m` and `n`
func lcm(_ m: Int, _ n: Int) -> Int { return m * n / gcd(m, n) }

let configCount = lcm(lcm(lcm(color.count, fontSize.count), mode.count), pool.count)
color = [[Int]](repeatElement(color, count: configCount / color.count)).flatMap { $0 }
fontSize = [[Int]](repeatElement(fontSize, count: configCount / fontSize.count)).flatMap { $0 }
mode = [[Int]](repeatElement(mode, count: configCount / mode.count)).flatMap { $0 }
pool = [[Int]](repeatElement(pool, count: configCount / pool.count)).flatMap { $0 }
let configs = zip(zip(color, fontSize), zip(mode, pool)).map {
    S2BDanmaku.Config(rgb: $0.0.0,
                      fontSize: S2BDanmaku.Config.FontSize(rawValue: $0.0.1),
                      mode: S2BDanmaku.Config.Mode(rawValue: $0.1.0),
                      pool: S2BDanmaku.Config.Pool(rawValue: $0.1.1))
}

// MARK: Post Danmaku
S2BVideo(av: aid).page(page) {
    guard let cid = $0?.cid, let title = $0?.pageName else { fatalError("无法获取该视频的信息") }
    print("发送弹幕到 \(title)\n")
    let emitter = S2BEmitter(cookie: cookie, delay: delay)
    emitter.post(srt: subRip, toCID: cid, configs: configs, updateHandler: { danmaku, progress in
        print("\(String(format: "%7.3f%%", progress.fractionCompleted * 100)) \(danmaku.content)")
    }) { _ in exit(0) }
}
// MARK: Wait Till Finish
// Enable indefinite execution to wait for asynchronous operation
RunLoop.current.run()
