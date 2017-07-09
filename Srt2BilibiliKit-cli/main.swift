//
//  main.swift
//  Srt2BilibiliKit-cli
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

let path = "/Users/Apollonian/Documents/Git-Repo/Developing-iOS-10-Apps-with-Swift/subtitles/2. MVC; iOS, Xcode and Swift Demonstration.srt"
let str = try! String(contentsOfFile: path)
let file = S2BSubRipFile(content: str)
var subtitles = file.subtitles

print(S2BCookie.default)
S2BVideo(av: 8997058)[0] { print($0!);exit(0) }

/*
S2BVideo(av: 8997058).p1 {
    guard let cid = $0?.cid else { fatalError("Failed to fetch CID") }
    func postNext() {
        guard subtitles.count > 0 else { exit(0) }
        let subtitle = subtitles.removeFirst()
        let danmuku = S2BDanmuku(subtitle.content[0], cid: cid, playTime: subtitle.startTime, fontSize: .small)
        post(danmuku: danmuku) {
            let danmuku = S2BDanmuku(subtitle.content[1], cid: cid, playTime: subtitle.startTime)
            post(danmuku: danmuku, completionHandler: postNext)
        }
    }
    postNext()
}
 */
// Enable indefinite execution to allow execution to continue asynchronous operation
while true { } //
