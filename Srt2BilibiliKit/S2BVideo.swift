//
//  S2BVideo.swift
//  Srt2BilibiliKit-cli
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public struct S2BVideo {
    public let aid: Int

    public init(av aid: Int) {
        self.aid = aid
    }

    public struct Part: Codable {
        public let page: Int
        public let pageName: String
        public let cid: Int

        enum CodingKeys: String, CodingKey {
            case page, cid
            case pageName = "pagename"
        }
    }

    public typealias PartsHandler = (_ parts: [Part]?) -> Void

    public func parts(handler: @escaping PartsHandler) {
        URLSession.shared.dataTask(with: URL(string: "http://www.bilibili.com/widget/getPageList?aid=\(aid)")!) { (data, _, _) in
            guard let data = data, let parts = try? JSONDecoder().decode([Part].self, from: data) else { return handler(nil) }
            handler(parts)
            }.resume()
    }

    public typealias PartHandler = (_ part: Part?) -> Void

    public func p1(handler: @escaping PartHandler) {
        parts { handler($0?.first) }
    }

    public func part(_ index: Int, handler: @escaping PartHandler) {
        // the index of the part to fetch, starting from 1.
        guard index > 0 else { return handler(nil) }
        parts {
            guard let parts = $0, index <= parts.count else { return handler(nil) }
            handler(parts[index - 1])
        }
    }

    public subscript(index: Int, handler: @escaping PartHandler) -> Void {
        get {
            part(index + 1, handler: handler)
        }
    }
}
