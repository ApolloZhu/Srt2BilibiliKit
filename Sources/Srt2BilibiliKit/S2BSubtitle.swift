//
//  S2BSubtitle.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

/// A segment of a .srt file.
public struct S2BSubtitle {
    /// Index of the subtitle.
    public let index: Int
    /// Time when the subtitle appears.
    public let startTime: TimeInterval
    /// Time when the subtitle disappears.
    public let endTime: TimeInterval
    /// Actual content of the subtitle.
    public let contents: [String]
    
    /// Initialize a subtitle with given information.
    ///
    /// - Parameters:
    ///   - index: the index of the subtitle.
    ///   - start: time of which the subtitle appears.
    ///   - end: time of which the subtitle disappears.
    ///   - contents: the actual content of the subtitle.
    public init(index: Int, from start: TimeInterval, to end: TimeInterval, contents: [String]) {
        self.index = index
        self.startTime = start
        self.endTime = end
        self.contents = contents
    }
    
    /// Initialize a subtitle with given information.
    ///
    /// - Parameters:
    ///   - index: the index of the subtitle.
    ///   - start: time of which the subtitle appears.
    ///   - end: time of which the subtitle disappears.
    ///   - contents: the actual content of the subtitle.
    public init(index: Int, from start: TimeInterval, to end: TimeInterval, contents: String...) {
        self.init(index: index, from: start, to: end, contents: contents)
    }
}

extension S2BSubtitle {
    /// Initialize a subtitle by parsing timestamp string.
    ///
    /// - Parameters:
    ///   - index: Index of the subtitle.
    ///   - time: String of format: start --> end.
    ///   - contents: Actual content of the subtitle.
    init(index: Int, time: String, contents: [String]) {
        self.index = index
        self.contents = contents
        let timestamps = time.components(separatedBy: " --> ")
        self.startTime = S2BSubtitle.timeInterval(from: timestamps[0])
        self.endTime = S2BSubtitle.timeInterval(from: timestamps[1])
    }
    
    /// Parsing SubRip timestamp to time interval.
    ///
    /// - Parameter string: valid string timestamp.
    /// - Returns: non-negative time interval.
    private static func timeInterval(from string: String) -> TimeInterval {
        let num = string.split(separator: ",")
            .flatMap { $0.split(separator: ":") }
            .filterOutNil { Double("\($0)") }
        return num[0] * 3600 + num[1] * 60 + num[2] + num[3] / 1000
    }
}

extension Sequence {
    /// Returns an array containing the non-`nil` results of calling the given
    /// transformation with each element of this sequence.
    ///
    /// Use this method to receive an array of nonoptional values when your
    /// transformation produces an optional value.
    ///
    /// In this example, note the difference in the result of using `map` and
    /// `filterOutNil` with a transformation that returns an optional `Int` value.
    ///
    ///     let possibleNumbers = ["1", "2", "three", "///4///", "5"]
    ///
    ///     let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
    ///     // [1, 2, nil, nil, 5]
    ///
    ///     let flatMapped: [Int] = filterOutNil { str in Int(str) }
    ///     // [1, 2, 5]
    ///
    /// - Parameter transform: A closure that accepts an element of this
    ///   sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-`nil` results of calling `transform`
    ///   with each element of the sequence.
    ///
    /// - Complexity: O(*m* + *n*), where *m* is the length of this sequence
    ///   and *n* is the length of the result.
    public func filterOutNil<ElementOfResult>(
        _ transform: (Self.Element) throws -> ElementOfResult?
        ) rethrows -> [ElementOfResult] {
        #if swift(>=4.1)
        return try compactMap(transform)
        #else
        return try flatMap(transform)
        #endif
    }
}

extension S2BSubtitle: CustomStringConvertible {
    /// SubRip representation of the subtitle.
    public var description: String {
        return """
        \(index)
        \(S2BSubtitle.string(from: startTime)) --> \(S2BSubtitle.string(from: endTime))
        \(contents.joined(separator: "\n"))
        """
    }
    
    /// Convert time interval to SubRip timestamp format.
    ///
    /// - Parameter interval: non-negative time interval to format.
    /// - Returns: valid string timestamp.
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
