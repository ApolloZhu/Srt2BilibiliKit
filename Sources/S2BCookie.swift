//
//  S2BCookie.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

/// Cookie required to post danmaku
public struct S2BCookie: Codable, CustomStringConvertible {
    
    /// Default S2BCookie as saved in a file named `bilicookies` at current working directory, which can be retrieved using https://github.com/dantmnf/biliupload/blob/master/getcookie.py .
    public static var `default`: S2BCookie! = S2BCookie()
    
    private let mid: Int
    private let md5Sum: String
    private let sessionData: String
    
    enum CodingKeys: String, CodingKey {
        case mid = "DedeUserID"
        case md5Sum = "DedeUserID__ckMd5"
        case sessionData = "SESSDATA"
    }
    
    /// Initialize a S2BCookie with required cookie value,
    /// available after login a bilibili account.
    ///
    /// - Parameters:
    ///   - DedeUserID: user's mid assigned by bilibili
    ///   - DedeUserID__ckMd5: md5 sum calculated by bilibili
    ///   - SESSDATA: some session data saved by bilibili
    public init(DedeUserID: Int, DedeUserID__ckMd5: String, SESSDATA: String) {
        mid = DedeUserID
        md5Sum = DedeUserID__ckMd5
        sessionData = SESSDATA
    }
    
    /// Initialize a S2BCookie with a file at directory,
    /// with contents of format `DedeUserID=xx;DedeUserID__ckMd5=xx;SESSDATA=xx`
    ///
    /// - Parameters:
    ///   - file: name of the file.
    ///   - directory: where the file is located.
    public init?(path: String? = nil) {
        guard let string = try? String(contentsOfFile: path
            ?? "\(FileManager.default.currentDirectoryPath)/bilicookies")
            else { return nil }
        var dict = [String:String]()
        for part in string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ";") {
                let parts = part
                    .split(separator: "=")
                    .map { "\($0)".trimmingCharacters(in: .whitespacesAndNewlines) }
                if parts.count == 2 { dict[parts[0]] = parts[1] }
        }
        guard let str = dict[CodingKeys.mid.stringValue],
            let mid = Int(str),
            let sum = dict[CodingKeys.md5Sum.stringValue],
            let data = dict[CodingKeys.sessionData.stringValue]
            else { return nil }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data)
    }

    public var description: String {
        return "\(CodingKeys.mid.stringValue)=\(mid);\(CodingKeys.md5Sum.stringValue)=\(md5Sum);\(CodingKeys.sessionData.stringValue)=\(sessionData)"
    }
}
