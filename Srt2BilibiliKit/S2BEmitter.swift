//
//  S2BEmitter.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/12/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public final class S2BEmitter {
    
    private let cookie: S2BCookie
    private let delay: Double
    private var isPosting = false
    
    public static let `default` = S2BEmitter()
    
    public static let bilibiliDelay = 4.0
    
    public init(cookie: S2BCookie! = .default, delay: Double = S2BEmitter.bilibiliDelay) {
        self.cookie = cookie
        self.delay = delay
    }
    
    public enum Error: Swift.Error {
        case unknown(Data?)
        case bilibiliRefused
    }
    
    /*
     headers = {'Origin': 'http://static.hdslb.com', 'X-Requested-With': 'ShockwaveFlash/15.0.0.223', 'Referer': 'http://static.hdslb.com/play.swf', 'User-Agent': BILIGRAB_UA, 'Host': 'interface.bilibili.com', 'Content-Type': 'application/x-www-form-urlencoded'}
     #print(headers)
     payload = {'fontsize': fontsize, 'message': message, 'mode': mode, 'pool': pool, 'color': color, 'date': getdate(), 'rnd': rnd, 'playTime': playTime, 'cid': cid}
     try:
     r = requests.post(url, data = payload, headers = headers, cookies=cookie)
     */
    
    public typealias FailablePostCompletionHandler = (_ id: Int?, _ postable: S2BPostableDanmaku, _ error: Swift.Error?) -> Void
    
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
                    self?.isPosting = false
                    guard error == nil else { completionHandler?(nil, postable, error!);return }
                    guard let datium = data, let content = String(data: datium, encoding: .utf8), let code = Int(content)
                        else { completionHandler?(nil, postable, Error.unknown(data));return }
                    guard code > 0 else { completionHandler?(code, postable, Error.bilibiliRefused);return }
                    completionHandler?(code, postable, nil)
                }
            }
            task.resume()
        }
    }
    
    public typealias PostCompletionHandler = (_ postable: S2BPostableDanmaku) -> Void
    
    public func post(danmaku: S2BDanmaku, completionHandler: PostCompletionHandler? = nil) {
        func emit() {
            tryPost(danmaku: danmaku) { id, postable, error in
                if error == nil, let id = id, id > 0 { completionHandler?(postable);return }
                emit()
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
                if contents.count < 1 {
                    progress.completedUnitCount = progress.totalUnitCount
                    completionHandler?()
                    return
                }
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
                 updateHandler: { danmaku, _ in updateHandler?(danmaku, progress) },
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
