//
//  S2BCookie.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public struct S2BCookie: Codable {
    private let mid: Int
    private let md5Sum: String
    private let sessionData: String

    enum CodingKeys: String, CodingKey {
        case mid = "DedeUserID"
        case md5Sum = "DedeUserID__ckMd5"
        case sessionData = "SESSDATA"
    }

    public init(DedeUserID: Int, DedeUserID__ckMd5: String, SESSDATA: String) {
        mid = DedeUserID
        md5Sum = DedeUserID__ckMd5
        sessionData = SESSDATA
    }
}

extension S2BCookie {
    public static var `default` = S2BCookie.init(file: "bilicookies", at: FileManager.default.currentDirectoryPath)

    public init?(file: String, at directory: String?) {
        guard let string = try? String(contentsOfFile: "\(directory ?? "")/\(file)")
            else { return nil }
        var dict = [String:String]()
        for part in string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ";") {
                let parts = part.split(separator: "=")
                dict["\(parts[0])"] = "\(parts[1])"
        }
        guard let str = dict[CodingKeys.mid.stringValue],
            let mid = Int(str),
            let sum = dict[CodingKeys.md5Sum.stringValue],
            let data = dict[CodingKeys.sessionData.stringValue]
            else { return nil }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data)
    }
}

extension S2BCookie: CustomStringConvertible {
    public var description: String {
        return "\(CodingKeys.mid.stringValue)=\(mid);\(CodingKeys.md5Sum.stringValue)=\(md5Sum);\(CodingKeys.sessionData.stringValue)=\(sessionData)"
    }
}
