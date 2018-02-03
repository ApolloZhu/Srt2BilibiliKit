//
//  S2BPostableDanmaku.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/12/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation
import BilibiliKit

/// Local danmaku ready for posting
public class S2BPostableDanmaku: S2BDanmaku, CustomStringConvertible {
    /// When the danmaku was/is/will be posted
    public let date: Date
    
    public init(_ danmaku: String, playTime: TimeInterval, config: Config = .default, date: Date = Date()) {
        self.date = date
        super.init(danmaku, playTime: playTime, config: config)
    }
    
    public convenience init(_ danmaku: String, playTime: TimeInterval, rgb color: Int? = nil, fontSize: Config.FontSize? = nil, mode: Config.Mode? = nil, pool: Config.Pool? = nil, date: Date = Date()) {
        self.init(danmaku, playTime: playTime,
                  config: .init(rgb: color, fontSize: fontSize, mode: mode, pool: pool), date: date)
    }
    
    public convenience init(_ raw: S2BDanmaku, date: Date = Date()) {
        self.init(raw.content, playTime: raw.playTime, config: raw.config, date: date)
    }
    
    /// Prepare a local danmaku for posting by assign its date of emission.
    ///
    /// - Parameters:
    ///   - raw: local danmaku.
    ///   - session: session providing csrf value.
    /// - Returns: A danmaku ready for http post request, and encoded data as request body.
    public static func byEncoding(_ raw: S2BDanmaku, cid: Int, forSession session: BKSession)
        -> (postable: S2BPostableDanmaku, data: Data?) {
            let postable = S2BPostableDanmaku(raw)
            guard let csrf = session.csrf else { return (postable, nil) }
            return (postable, "\(postable)&cid=\(cid)&csrf=\(csrf)".data(using: .utf8))
    }
    
    /// String representation of post request body
    public var description: String {
        let date: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: self.date)
        }()
        return "fontsize=\(config.fontSize.rawValue)&message=\(content)&mode=\(config.mode.rawValue)&pool=\(config.pool.rawValue)&color=\(config.color)&date=\(date)&rnd=\(S2B.kit.random)&playTime=\(playTime)"
    }
}
