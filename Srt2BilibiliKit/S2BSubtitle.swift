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
    public let content: [String]
}

extension S2BSubtitle {
    public init(index: Int, from start: TimeInterval, to end: TimeInterval, content: String...) {
        self.index = index
        self.startTime = start
        self.endTime = end
        self.content = content
    }
}

extension S2BSubtitle {
    init(index: Int, time: String, content: [String]) {
        self.index = index
        self.content = content
        let timestamps = time.components(separatedBy: " --> ")
        self.startTime = S2BSubtitle.interval(from: timestamps[0])
        self.endTime = S2BSubtitle.interval(from: timestamps[1])
    }

    private static func interval(from string: String) -> TimeInterval {
        var dict = string.split(separator: ","), major = dict[0].split(separator: ":").map { Double("\($0)")! }
        let (h,m,s,c) = (major[0], major[1], major[2], Double("\(dict[1])")!)
        return h * 3600 + m * 60 + s + c / 1000
    }
}

extension S2BSubtitle: CustomStringConvertible {
    public var description: String {
        return """
        \(index)
        \(S2BSubtitle.string(from: startTime)) --> \(S2BSubtitle.string(from: endTime))
        \(content.joined(separator: "\n"))
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
