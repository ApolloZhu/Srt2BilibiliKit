//
//  S2BSRTFile.swift
//  srt2bilibili-cli
//
//  Created by Apollo Zhu on 7/8/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public struct S2BSRTSubtitle: CustomStringConvertible {
    public let index: Int
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let content: [String]
    init(index: Int, time: String, content: [String]) {
        self.index = index
        self.content = content
        let timestamps = time.components(separatedBy: " --> ")
        self.startTime = S2BSRTSubtitle.interval(from: timestamps[0])
        self.endTime = S2BSRTSubtitle.interval(from: timestamps[1])
    }
    private static func interval(from string: String) -> TimeInterval {
        var dict = string.split(separator: ","), major = dict[0].split(separator: ":").map { Double("\($0)")! }
        let (h,m,s,c) = (major[0], major[1], major[2], Double("\(dict[1])")!)
        return h * 3600 + m * 60 + s + c / 1000
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
    public var description: String {
        return "\(index)\n\(S2BSRTSubtitle.string(from: startTime)) --> \(S2BSRTSubtitle.string(from: endTime))\n\(content.joined(separator: "\n"))"
    }
}

struct S2BSRTFile: CustomStringConvertible {
    var subtitles = [S2BSRTSubtitle]()
    enum ParseState {
        case index
        case time
        case content
    }
    public init(_ string: String) {
        for part in string.components(separatedBy: "\n\n") {
            var state = ParseState.index
            var index: Int? = nil
            var time: String? = nil
            var content = [String]()
            for line in part.split(separator: "\n") {
                let line = "\(line)".trimmingCharacters(in: .whitespacesAndNewlines)
                switch state {
                case .index:
                    if let i = Int(line) {
                        index = i
                        state = .time
                    }
                case .time:
                    if line.contains("-->") {
                        time = line
                        state = .content
                    }
                case .content:
                    if line.count > 0 {
                        content.append(line)
                    }
                }
            }
            subtitles.append(.init(index: index!, time: time!, content: content))
        }
    }
    var description: String {
        return subtitles.map({ $0.description }).joined(separator: "\n")
    }
}
