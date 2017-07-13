//
//  main.swift
//  Srt2BilibiliKit-cli
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation
import Srt2BilibiliKit

// MARK: Usage/Help

let usage = """

usage: s2bkit [-h] -a avNumber -s subRipFile [-p 1] [-c ./bilicookies] [-o \(S2BDanmaku.Config.default.color)...] [-f \(S2BDanmaku.Config.default.fontSize.rawValue)...] [-m \(S2BDanmaku.Config.default.mode.rawValue)...] [-l \(S2BDanmaku.Config.default.pool.rawValue)...] [-w \(S2BEmitter.defaultDelay)]

-h (optional)
\tPrint the usage

-a aid (required)
\tThe av number to post to

-s srt (required)
\tThe srt file you to post.

-p page (default 1)
\tThe page/part number.

-c cookie (default ./bilicookies)
\tThe path to the cookie file, requirement for posting danmaku
\tRetrieved using https://github.com/dantmnf/biliupload/blob/master/getcookie.py, has structure similar to
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

func exitAfterPrintingUsage() -> Never { print(usage);exit(0) }

// MARK: Parse

var aid: Int?
var srt: String?
var page = 1
var cookie: String? = nil
var color = [Int]()
var fontSize = [Int]()
var mode = [Int]()
var pool = [Int]()
var delay = S2BEmitter.defaultDelay

//let arguments = ["s2bkit", "-l", "1", "-f", "18", "25", "-a", "8997583", "-s", "/Users/Apollonian/Documents/Git-Repo/Developing-iOS-10-Apps-with-Swift/subtitles/3. More Swift and the Foundation Framework.srt", "-c", "/Users/Apollonian/bilicookies"]
let arguments = CommandLine.arguments

guard arguments.count > 1 else { exitAfterPrintingUsage() }
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
        cookie = next()
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

// MARK: Check Required

guard let aid = aid else { fatalError("AV number is REQUIRED") }
guard let path = srt, var subRip = S2BSubRipFile(path: path) else { fatalError("Path to srt file is REQUIRED") }
guard let cookie = S2BCookie(path: cookie) else { fatalError("Unable to load cookie") }

// MARK: Zip Configs

if color.count == 0 { color = [S2BDanmaku.Config.default.color] }
if fontSize.count == 0 { fontSize = [S2BDanmaku.Config.default.fontSize.rawValue] }
if mode.count == 0 { mode = [S2BDanmaku.Config.default.mode.rawValue] }
if pool.count == 0 { pool = [S2BDanmaku.Config.default.pool.rawValue] }

func gcd(_ m: Int, _ n: Int) -> Int { return n == 0 ? m : gcd(n, m % n) }
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
    guard let cid = $0?.cid, let title = $0?.pageName else { fatalError("Unable to fetch video") }
    print("Posting to \(title)\n")
    let emitter = S2BEmitter(cookie: cookie, delay: delay)
    emitter.post(srt: subRip, toCID: cid, configs: configs, updateHandler: { danmaku, progress in
        print("\(String(format: "%7.3f%%", progress.fractionCompleted * 100)) \(danmaku.content)")
    }) { exit(0) }
}

// MARK: Wait

// Enable indefinite execution to wait for asynchronous operation
RunLoop.current.run()
