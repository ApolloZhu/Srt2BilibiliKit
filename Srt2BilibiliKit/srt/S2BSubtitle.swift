//
//  S2BSubtitle.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public struct S2BSubtitle {
    public let index: Int
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let contents: [String]

    public init(index: Int, from start: TimeInterval, to end: TimeInterval, contents: [String]) {
        self.index = index
        self.startTime = start
        self.endTime = end
        self.contents = contents
    }

    public init(index: Int, from start: TimeInterval, to end: TimeInterval, contents: String...) {
        self.init(index: index, from: start, to: end, contents: contents)
    }
}

extension S2BSubtitle {
    init(index: Int, time: String, contents: [String]) {
        self.index = index
        self.contents = contents
        let timestamps = time.components(separatedBy: " --> ")
        self.startTime = S2BSubtitle.timeInterval(from: timestamps[0])
        self.endTime = S2BSubtitle.timeInterval(from: timestamps[1])
    }

    private static func timeInterval(from string: String) -> TimeInterval {
        let num = string.split(separator: ",")
            .flatMap { $0.split(separator: ":") }
            .flatMap { Double("\($0)") }
        return num[0] * 3600 + num[1] * 60 + num[2] + num[3] / 1000
    }
}

extension S2BSubtitle: CustomStringConvertible {
    public var description: String {
        return """
        \(index)
        \(S2BSubtitle.string(from: startTime)) --> \(S2BSubtitle.string(from: endTime))
        \(contents.joined(separator: "\n"))
        """
    }

    private static func string(from interval: TimeInterval) -> String {
        let h = Int(interval / 3600)
        var interval = interval.remainder(dividingBy: 3600)
        if interval < 0 { interval += 3600 }
        let m = Int(interval / 60)
        interval = interval.remainder(dividingBy: 60)
        if interval < 0 { interval += 60 }
        let s = Int(interval)
        interval = interval.remainder(dividingBy: 1)
        if interval < 0 { interval += 1 }
        let c = Int(interval * 1000)
        return  "\(h):\(m):\(s),\(c)"
    }
}
