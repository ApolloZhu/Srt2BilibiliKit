//
//  S2BEmitter.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/12/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation
import Dispatch

/// Danmaku "poster"
public final class S2BEmitter {
    /// Default emitter.
    public static let `default` = S2BEmitter()
    
    /// Cookie required for posting danmaku
    private let cookie: S2BCookie
    /// Cool time in seconds (time to wait before posting the next one).
    private let delay: Double
    
    /// Suggested cool time between sending danmaku in seconds.
    /// Number smaller than the default may result in ban or failure.
    public static let defaultDelay: Double = 3.5
    
    /// Initalize a S2BEmitter with specified cookie and delay.
    ///
    /// - Parameters:
    ///   - cookie: cookie required for posting danmaku.
    ///   - delay: cool time between sending danmaku in seconds.
    public init(cookie: S2BCookie! = .default, delay: Double = S2BEmitter.defaultDelay) {
        self.cookie = cookie
        self.delay = delay
    }
    
    /// Result after trying to post a danmaku.
    ///
    /// - success: danmaku was successfully posted.
    /// - refused: bilibili refused to accept the postable danmaku.
    /// - aborted: something else went wrong.
    public enum Result {
        /// Danmaku was successfully posted.
        case success(posted: S2BPostedDanmaku)
        /// Bilibili refused to accept the postable danmaku.
        case refused(danmaku: S2BPostableDanmaku, id: Int)
        /// Something else went wrong.
        case aborted(danmaku: S2BPostableDanmaku, data: Data?, error: Error?)
    }

    /// To handle result after tring to post a danmaku.
    ///
    /// - Parameter result: result after trying to post a danmaku.
    public typealias FailablePostCompletionHandler = (_ result: Result) -> Void

    /// To keep track of the current state.
    private var isPosting = false
    
    /*
     headers = {'Origin': 'http://static.hdslb.com', 'X-Requested-With': 'ShockwaveFlash/15.0.0.223', 'Referer': 'http://static.hdslb.com/play.swf', 'User-Agent': BILIGRAB_UA, 'Host': 'interface.bilibili.com', 'Content-Type': 'application/x-www-form-urlencoded'}
     #print(headers)
     payload = {'fontsize': fontsize, 'message': message, 'mode': mode, 'pool': pool, 'color': color, 'date': getdate(), 'rnd': rnd, 'playTime': playTime, 'cid': cid}
     try:
     r = requests.post(url, data = payload, headers = headers, cookies=cookie)
     */
    
    /// Try to post a danmaku.
    ///
    /// - Parameters:
    ///   - danmaku: danmaku to post.
    ///   - completionHandler: task to perform once tried.
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
            let task = S2B.kit.urlSession.dataTask(with: request) { [delay] (data, response, error) in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                    guard let this = self, error == nil, let datium = data,
                        let content = String(data: datium, encoding: .utf8), let id = Int(content)
                        else { completionHandler?(.aborted(danmaku: postable, data: data, error: error));return }
                    this.isPosting = false
                    guard id > 0
                        else { completionHandler?(.refused(danmaku: postable, id: id));return }
                    completionHandler?(.success(posted: S2BPostedDanmaku.byAssigning(postable, id: id)))
                }
            }
            task.resume()
        }
    }
}

public extension S2BEmitter {
    /// Task to perform once a single danmaku was posted.
    ///
    /// - Parameter postable: danmaku posted.
    public typealias PostCompletionHandler = (_ posted: S2BPostedDanmaku) -> Void
    
    /// Post a danmaku, auto retry if failed.
    ///
    /// - Parameters:
    ///   - danmaku: danmaku to post.
    ///   - completionHandler: task to perform once the danmaku was successfully posted.
    public func post(danmaku: S2BDanmaku, completionHandler: PostCompletionHandler? = nil) {
        func emit() {
            tryPost(danmaku: danmaku) { result in
                guard case let .success(posted) = result else { return emit() }
                completionHandler?(posted)
            }
        }
        emit()
    }
    
    /// Task to perform once a danmaku in the queue was posted.
    ///
    /// - Parameters:
    ///   - postable: danmaku posted.
    ///   - progress: object tracking the current progress.
    public typealias ProgressReportHandler = (_ posted: S2BPostedDanmaku, _ progress: Progress) -> Void
    
    /// Task to perform once completed.
    ///
    /// - Parameter posted: all danmaku posted.
    public typealias CompletionHandler = (_ posted: [S2BPostedDanmaku]) -> Void
    
    /// Post all contents within the subtile to video of given cid.
    ///
    /// - Parameters:
    ///   - subtitle: subtitle to post.
    ///   - cid: cid of the video to post to.
    ///   - configs: configurations of danmakus.
    ///   - updateHandler: task to perform once a danmaku was posted.
    ///   - completionHandler: task to perform after all danmaku were posted.
    public func post(subtitle: S2BSubtitle, toCID cid: Int, configs: [S2BDanmaku.Config] = [.default], updateHandler: ProgressReportHandler? = nil, completionHandler: CompletionHandler? = nil) {
        var contents = subtitle.contents
        guard contents.count > 0 else { completionHandler?([]);return }
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
        var allPosted = [S2BPostedDanmaku]()
        func emit() {
            post(danmaku: S2BDanmaku(danmaku, cid: cid, playTime: subtitle.startTime, config: config)) { posted in
                progress.completedUnitCount += 1
                allPosted.append(posted)
                updateHandler?(posted, progress)
                guard contents.count > 0 else { completionHandler?(allPosted);return }
                danmaku = contents.removeFirst()
                config = configs.removeFirst()
                emit()
            }
        }
        emit()
    }
    
    /// Post all contents within the file to video of given cid.
    ///
    /// - Parameters:
    ///   - srt: SubRip file to post.
    ///   - cid: cid of the video to post to.
    ///   - configs: configurations of danmakus.
    ///   - updateHandler: task to perform once a danmaku was posted.
    ///   - completionHandler: task to perform after all danmaku were posted.
    public func post(srt: S2BSubRipFile, toCID cid: Int, configs: [S2BDanmaku.Config] = [.default], updateHandler: ProgressReportHandler? = nil, completionHandler: CompletionHandler? = nil) {
        var subs = srt.subtitles
        guard subs.count > 0 else { completionHandler?([]);return }
        var progress = Progress(totalUnitCount: Int64(subs.count))
        var sub = subs.removeFirst()
        func emit() {
            progress.becomeCurrent(withPendingUnitCount: 1)
            post(subtitle: sub, toCID: cid, configs: configs,
                 updateHandler: { posted, _ /*sub progress*/ in updateHandler?(posted, progress) },
                 completionHandler: { posted in
                    if subs.count < 1 { completionHandler?(posted);return }
                    sub = subs.removeFirst()
                    emit()
            })
            progress.resignCurrent()
        }
        emit()
    }
}
