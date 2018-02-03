//
//  S2BSubRipFile.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/8/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

/// A .srt file
public struct S2BSubRipFile {
    /// Subtitles within the srt file.
    public var subtitles = [S2BSubtitle]()
}

extension S2BSubRipFile {
    /// Initialize a S2BSubRipFile with its content.
    ///
    /// - Parameter content: content of a srt file.
    public init(content: String) {
        /// Indicating what the next piece of information is
        enum ParsingState { case index, time, content }
        
        let lineSeparator: String
        if content.contains("\r\n") {
            lineSeparator = "\r\n"
        } else if content.contains("r") {
            lineSeparator = "\r"
        } else {
            lineSeparator = "\n"
        }
        
        for part in content.components(separatedBy: "\(lineSeparator)\(lineSeparator)").lazy {
            var state = ParsingState.index
            var index: Int? = nil
            var time: String? = nil
            var content = [String]()
            for line in part.components(separatedBy: lineSeparator) {
                let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
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
            if let i = index, let t = time, content.count > 0 {
                subtitles.append(.init(index: i, time: t, contents: content))
            }
        }
    }
}

extension S2BSubRipFile {
    /// Initialize a S2BSubRipFile with the url, nil if file not found.
    ///
    /// - Parameters:
    ///   - url: url to the srt file.
    ///   - enc: encoding of the file content.
    public init?(url: URL, stringEncoding enc: String.Encoding = .utf8) {
        guard let content = try? String(contentsOf: url, encoding: enc) else { return nil }
        self.init(content: content)
    }
    
    /// Initialize a S2BSubRipFile with its path, nil if file not found.
    ///
    /// - Parameters:
    ///   - path: path to the srt file.
    ///   - enc: encoding of the file content.
    public init?(path: String, stringEncoding enc: String.Encoding = .utf8) {
        guard let content = try? String(contentsOfFile: path, encoding: enc) else { return nil }
        self.init(content: content)
    }
}

extension S2BSubRipFile: CustomStringConvertible {
    /// Convert back to what it would be like in a .srt file.
    public var description: String {
        return subtitles.map({ $0.description }).joined(separator: "\n")
    }
}
