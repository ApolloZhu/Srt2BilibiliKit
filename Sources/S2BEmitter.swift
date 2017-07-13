//
//  S2BEmitter.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/12/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public final class S2BEmitter {
    
    /// Default emitter.
    public static let `default` = S2BEmitter()
    
    /// Cookie required for posting danmaku
    private let cookie: S2BCookie
    /// Cool time in seconds (time to wait before posting the next one).
    private let delay: Double
    
    /// Suggested cool time between sending danmaku in seconds.
    /// Number smaller than the default may result in ban or failure.
    public static let defaultDelay = 3.5
    
    /// Initalize a S2BEmitter with specified cookie and delay.
    ///
    /// - Parameters:
    ///   - cookie: cookie required for posting danmaku.
    ///   - delay: cool time between sending danmaku in seconds.
    public init(cookie: S2BCookie! = .default, delay: Double = S2BEmitter.defaultDelay) {
        self.cookie = cookie
        self.delay = delay
    }
    
    /// Result after trying to post danmaku
    ///
    /// - success: danmaku was successfully posted
    /// - refused: bilibili refused to accept the posted danmaku
    /// - aborted: something else went wrong
    public enum Result {
        case success(danmaku: S2BPostableDanmaku, id: Int)
        case refused(danmaku: S2BPostableDanmaku, id: Int)
        case aborted(danmaku: S2BPostableDanmaku, data: Data?, error: Error?)
    }
    
    public typealias FailablePostCompletionHandler = (Result) -> Void
    
    private var isPosting = false
    
    /*
     headers = {'Origin': 'http://static.hdslb.com', 'X-Requested-With': 'ShockwaveFlash/15.0.0.223', 'Referer': 'http://static.hdslb.com/play.swf', 'User-Agent': BILIGRAB_UA, 'Host': 'interface.bilibili.com', 'Content-Type': 'application/x-www-form-urlencoded'}
     #print(headers)
     payload = {'fontsize': fontsize, 'message': message, 'mode': mode, 'pool': pool, 'color': color, 'date': getdate(), 'rnd': rnd, 'playTime': playTime, 'cid': cid}
     try:
     r = requests.post(url, data = payload, headers = headers, cookies=cookie)
     */
    public func tryPost(danmaku: S2BDanmaku, completionHandler: FailablePostCompletionHandler? = nil) {
        if isPosting {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                self?.tryPost(danmaku: danmaku, completionHandler: completionHandler)
            }
        } else {
            isPosting = true
            var request = URLRequest(url: URL(string: "http://interface.bilibili.com/dmpost")!)
            let (postable, data) = S2BPostableDanmaku.byEncoding(danmaku)
            request.httpBody = data
            request.httpMethod = "POST"
            request.addValue("Srt2BilibiliKit", forHTTPHeaderField: "User-Agent")
            request.addValue(cookie.description, forHTTPHeaderField: "Cookie")
            let task = URLSession.shared.dataTask(with: request) { [delay] (data, response, error) in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                    guard let this = self, error == nil, let datium = data,
                        let content = String(data: datium, encoding: .utf8), let id = Int(content)
                        else { completionHandler?(.aborted(danmaku: postable, data: data, error: error));return }
                    this.isPosting = false
                    guard id > 0
                        else { completionHandler?(.refused(danmaku: postable, id: id));return }
                    this.verify(id, ofCID: postable.cid) { isValid in
                        if isValid { completionHandler?(.success(danmaku: postable, id: id)) }
                        else { completionHandler?(.refused(danmaku: postable, id: id)) }
                    }
                }
            }
            task.resume()
        }
    }
    
    public typealias ValidationCompletionHandler = (Bool) -> Void
    
    private func verify(_ id: Int, ofCID cid: Int, isValid handler: @escaping ValidationCompletionHandler) {
        let url = URL(string: "https://comment.bilibili.com/\(cid).xml")!
        let parser = XMLParser(contentsOf: url)!
        let delegate = ParsingDelegate(target: id, handler: handler)
        parser.delegate = delegate
        parser.parse()
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
    private class ParsingDelegate: NSObject, XMLParserDelegate {
        private let targetID: Int
        private let completionHandler: ValidationCompletionHandler
        public init(target id: Int, handler: @escaping ValidationCompletionHandler) {
            self.targetID = id
            self.completionHandler = handler
        }
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            if elementName == "d",
                let rawID = attributeDict["p"]?.split(separator: ",").last,
                let did = Int("\(rawID)"),
                did == targetID {
                parser.abortParsing()
                completionHandler(true)
            }
        }
        
        func parserDidEndDocument(_ parser: XMLParser) { completionHandler(false) }
    }
}

public extension S2BEmitter {
    
    public typealias PostCompletionHandler = (_ postable: S2BPostableDanmaku) -> Void
    
    public func post(danmaku: S2BDanmaku, completionHandler: PostCompletionHandler? = nil) {
        func emit() {
            tryPost(danmaku: danmaku) { result in
                guard case let .success(postable, _) = result else { return emit() }
                completionHandler?(postable)
            }
        }
        emit()
    }
    
    public typealias ProgressReportHandler = (_ postable: S2BPostableDanmaku, _ progress: Progress) -> Void
    public typealias CompletionHandler = () -> Void
    
    public func post(subtitle: S2BSubtitle, toCID cid: Int, configs: [S2BDanmaku.Config] = [.default], updateHandler: ProgressReportHandler? = nil, completionHandler: CompletionHandler? = nil) {
        var contents = subtitle.contents
        guard contents.count > 0 else { completionHandler?();return }
        var progress = Progress(totalUnitCount: Int64(contents.count))
        var configs = configs.count < 1 ? [S2BDanmaku.Config.default] : configs
        if contents.count > configs.count {
            configs = Array<[S2BDanmaku.Config]>(
                repeatElement(configs,
                              count: (contents.count + contents.count % configs.count) / configs.count))
                .flatMap { $0 }
        }
        var danmaku = contents.removeFirst()
        var config = configs.removeFirst()
        func emit() {
            post(danmaku: S2BDanmaku(danmaku, cid: cid, playTime: subtitle.startTime, config: config)) { postable in
                progress.completedUnitCount += 1
                updateHandler?(postable, progress)
                guard contents.count > 0 else { completionHandler?();return }
                danmaku = contents.removeFirst()
                config = configs.removeFirst()
                emit()
            }
        }
        emit()
    }
    
    public func post(srt: S2BSubRipFile, toCID cid: Int, configs: [S2BDanmaku.Config] = [.default], updateHandler: ProgressReportHandler? = nil, completionHandler: CompletionHandler? = nil) {
        var subs = srt.subtitles
        guard subs.count > 0 else { completionHandler?();return }
        var progress = Progress(totalUnitCount: Int64(subs.count))
        var sub = subs.removeFirst()
        func emit() {
            progress.becomeCurrent(withPendingUnitCount: 1)
            post(subtitle: sub, toCID: cid, configs: configs,
                 updateHandler: { postable, _ in updateHandler?(postable, progress) },
                 completionHandler: {
                    if subs.count < 1 { completionHandler?();return }
                    sub = subs.removeFirst()
                    emit()
            })
            progress.resignCurrent()
        }
        emit()
    }
    
}
