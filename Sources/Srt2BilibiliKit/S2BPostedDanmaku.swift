//
//  S2BPostedDanmaku.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/13/17.
//

import Foundation

/// Danmaku fetched from server
public class S2BPostedDanmaku: S2BPostableDanmaku {
    /// CID of the video this danmaku is posted to.
    public let cid: Int
    
    /// Unique identifier of the danmaku.
    public let id: Int
    
    /// Encrypted mid indicating the sender of danmaku,
    /// nil if was initialized locally.
    public let sender: Int?
    
    /// If is constructed locally or generated from bilibili server result.
    public var wasInitializedLocally: Bool { return sender == nil }
    
    public init(_ danmaku: String, cid: Int, playTime: TimeInterval, config: Config, date: Date, id: Int, sender: Int? = nil) {
        self.sender = sender
        self.id = id
        self.cid = cid
        super.init(danmaku, playTime: playTime, config: config)
    }
    
    public convenience init(_ danmaku: String, cid: Int, playTime: TimeInterval, rgb color: Int, fontSize: Config.FontSize!, mode: Config.Mode!, pool: Config.Pool!, date: Date, id: Int, sender: Int? = nil) {
        self.init(danmaku, cid: cid, playTime: playTime,
                  config: .init(rgb: color, fontSize: fontSize, mode: mode, pool: pool), date: date, id: id, sender: sender)
    }
    
    /// Constructs a new posted danmaku with given id.
    ///
    /// - Parameters:
    ///   - postable: a postable danmaku.
    ///   - id: id returned by bilibili.
    /// - Returns: a posted danmaku with given id.
    static func byAssigning(_ postable: S2BPostableDanmaku, cid: Int, id: Int) -> S2BPostedDanmaku {
        return S2BPostedDanmaku(postable.content, cid: cid, playTime: postable.playTime, config: postable.config, date: postable.date, id: id)
    }
    
    /// Initialize a new posted danmaku with xml attribute,
    /// as in form returned by bilibili server, like the following:
    ///
    /// <d p="946.86199951172,1,25,16777215,1494981458,0,f9c4a4cd,3366547626">1. MVC see other MVCs as Views.</d>
    ///
    /// - Parameters:
    ///   - p: xml attribute named p.
    ///   - cid: cid in which the danmaku was posted to.
    ///   - content: content of the danmaku.
    public convenience init!(xmlAttribute p: String, cid: Int, content: String) {
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
        self.init(content, cid: cid, playTime: playTime, rgb: color, fontSize: size, mode: mode, pool: pool, date: date, id: id, sender: sender)
    }
    
    /// To process all danmaku associated.
    ///
    /// - Parameter allDanmaku: all the danmaku for a video.
    public typealias AllDanmakuHandler = (_ allDanmaku: [S2BPostedDanmaku]) -> Void
    
    /// Fetch all danmaku in the given cid.
    ///
    /// - Parameters:
    ///   - cid: cid which to query danmaku from.
    ///   - handler: to process all danmaku associated.
    public static func allDanmaku(ofCID cid: Int, _ handler: @escaping AllDanmakuHandler) {
        let delegate = DanmakuXMLParserDelegate()
        delegate.handler = handler
        delegate.cid = cid
        let url = URL(string: "https://comment.bilibili.com/\(cid).xml")!
        let parser = XMLParser(contentsOf: url)!
        parser.delegate = delegate
        let _ = parser.parse()
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
     */
    /// TODO: Parser for danmaku in xml format, as returned by the bilibili server.
    private class DanmakuXMLParserDelegate: NSObject, XMLParserDelegate {
        var handler: AllDanmakuHandler!
        var cid: Int!
        
        var posted = [S2BPostedDanmaku]()
        
        private var curAttr: String?
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            guard elementName == "d" else { return }
            curAttr = attributeDict["p"]!
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if let attr = curAttr {
                posted.append(.init(xmlAttribute: attr, cid: cid, content: string))
                curAttr = nil
            }
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            guard curAttr == nil else { fatalError() }
        }
        
        func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
            handler(posted)
            fatalError()
        }
        
        func parserDidEndDocument(_ parser: XMLParser) {
            handler(posted)
        }
    }
}

extension S2BPostedDanmaku: Equatable {
    /// Check if two posted danmaku are theoretically identical.
    ///
    /// - Parameters:
    ///   - lhs: A posted danmaku
    ///   - rhs: Another posted danmaku.
    /// - Returns: true if they have the same id and cid, false otherwise.
    public static func ==(lhs: S2BPostedDanmaku, rhs: S2BPostedDanmaku) -> Bool {
        return lhs.cid == rhs.cid && lhs.id == rhs.id
    }
}
