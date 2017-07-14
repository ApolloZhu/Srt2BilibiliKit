//
//  S2BPostedDanmaku.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/13/17.
//

import Foundation

/// Danmaku fetched from server
public class S2BPostedDanmaku: S2BPostableDanmaku {
    
    /// Encrypted mid indicating the sender of danmaku
    public let sender: Int
    /// Unique identifier of the danmaku
    public let id: Int
    
    public init(_ danmaku: String, cid: Int, playTime: TimeInterval, config: Config = .default, date: Date, sender: Int, id: Int) {
        self.sender = sender
        self.id = id
        super.init(danmaku, cid: cid, playTime: playTime, config: config)
    }
    
    public convenience init(_ danmaku: String, cid: Int, playTime: TimeInterval, rgb color: Int, fontSize: Config.FontSize!, mode: Config.Mode!, pool: Config.Pool!, date: Date, sender: Int, id: Int) {
        self.init(danmaku, cid: cid, playTime: playTime,
                  config: .init(rgb: color, fontSize: fontSize, mode: mode, pool: pool), date: date, sender: sender, id: id)
    }
    
    /*
     <i>
     <chatserver>chat.bilibili.com</chatserver>
     <chatid>14855219</chatid>
     <mission>0</mission>
     <maxlimit>8000</maxlimit>
     <source>k-v</source>
     <d p="946.86199951172,1,25,16777215,1494981458,0,f9c4a4cd,3366547626">1. MVC see other MVCs as Views.</d>
     ...
     </i>
     
     public typealias ValidationCompletionHandler = (_ isValid: Bool) -> Void
     
     private func verify(_ id: Int, ofCID cid: Int, isValid handler: @escaping ValidationCompletionHandler) {
     let url = URL(string: "https://comment.bilibili.com/\(cid).xml")!
     let parser = XMLParser(contentsOf: url)!
     let delegate = <#XMLParserDelegate#>
     parser.delegate = delegate
     parser.parse()
     }
     */
    convenience init?(xmlAttribute p: String, cid: Int, content: String) {
        let parts = p.components(separatedBy: ",")
        guard parts.count == 8 else { return nil }
        guard let playTime = TimeInterval(parts[0]) else { return nil }
        guard let iMode = Int(parts[1]),
            let mode = S2BDanmaku.Config.Mode(rawValue: iMode) else { return nil }
        guard let iSize = Int(parts[2]),
            let size = S2BDanmaku.Config.FontSize(rawValue: iSize) else { return nil }
        guard let color = Int(parts[3]) else { return nil }
        guard let iDate = TimeInterval(parts[4]) else { return nil }
        let date = Date(timeIntervalSince1970: iDate)
        guard let iPool = Int(parts[5]),
            let pool = S2BDanmaku.Config.Pool(rawValue: iPool) else { return nil }
        guard let sender = Int(parts[6], radix: 16) else { return nil }
        guard let id = Int(parts[7]) else { return nil }
        self.init(content, cid: cid, playTime: playTime, rgb: color, fontSize: size, mode: mode, pool: pool, date: date, sender: sender, id: id)
    }
}
