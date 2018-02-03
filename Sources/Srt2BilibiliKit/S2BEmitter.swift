//
//  S2BEmitter.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/12/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation
import Dispatch
import BilibiliKit

/// Danmaku "poster"
public final class S2BEmitter {
    /// Default emitter.
    public static let `default` = S2BEmitter()
    
    /// Cookie required for posting danmaku
    private let session: BKSession
    
    /// Cool time in seconds (time to wait before posting the next one).
    private let delay: Double
    
    /// Suggested cool time between sending danmaku in seconds.
    /// Number smaller than the default may result in ban or failure.
    public static let defaultDelay: Double = 3.5
    
    /// Initalize a S2BEmitter with specified session and delay.
    ///
    /// - Parameters:
    ///   - session: session containing cookie required for posting danmaku.
    ///   - delay: cool time between sending danmaku in seconds.
    public init(session: BKSession! = .shared, delay: Double = S2BEmitter.defaultDelay) {
        self.session = session
        self.delay = delay
    }
    
    /// Initalize a S2BEmitter with specified
    /// cookie to add to the default session and delay.
    ///
    /// - Parameters:
    ///   - cookie: cookie to be added to the default session.
    ///   - delay: cool time between sending danmaku in seconds.
    public convenience init(cookie: BKCookie, delay: Double = S2BEmitter.defaultDelay) {
        BKSession.shared.cookie = cookie
        self.init(delay: delay)
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
        case refused(danmaku: S2BPostableDanmaku, message: String, code: Int)
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
    public func tryPost(danmaku: S2BDanmaku, toPage page: BKVideo.Page, completionHandler: FailablePostCompletionHandler? = nil) {
        if isPosting {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                self?.tryPost(danmaku: danmaku, toPage: page, completionHandler: completionHandler)
            }
        } else {
            isPosting = true
            let str = "https://interface.bilibili.com/dmpost?cid=\(page.cid)&aid=\(page.aid!)&pid=\(page.page)&ct=1"
            var request = session.postRequest(to: URL(string: str)!)
            let (postable, data) = S2BPostableDanmaku.byEncoding(danmaku, cid: page.cid, forSession: session)
            request.httpBody = data
            request.addValue("Srt2BilibiliKit", forHTTPHeaderField: "User-Agent")
            let task = S2B.kit.urlSession.dataTask(with: request) { [weak self, delay] (data, response, error) in
                guard let handle = completionHandler else { self?.isPosting = false;return }
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                    if let this = self, error == nil, let datium = data {
                        this.isPosting = false
                        if let result = try? JSONDecoder().decode(Success.self, from: datium), result.code == 0 {
                            return handle(.success(posted: S2BPostedDanmaku.byAssigning(postable, cid: page.cid, id: result.dmid)))
                        } else if let result = try? JSONDecoder().decode(Failure.self, from: datium) {
                            return handle(.refused(danmaku: postable, message: result.message, code: result.code))
                        }
                    }
                    handle(.aborted(danmaku: postable, data: data, error: error))
                }
            }
            task.resume()
        }
    }
    
    private struct Success: Codable {
        /// Should always be 0
        let code: Int
        /// ID assigned to this posted danmaku.
        let dmid: Int
    }

    private struct Failure: Codable {
        /// Some negative number informing the error state.
        let code: Int
        /// Error message in Simplified Chinese.
        let message: String
        /// I don't care what this is.
        let ts: Int

        static let errorCodes = [
            0:"系统错误，发送失败。",
            -1:"选择的弹幕模式错误。",
            -2:"用户被禁止。",
            -3:"系统禁止。",
            -4:"投稿不存在。",
            -5:"UP主禁止。",
            -6:"权限有误。",
            -7:"视频未审核/未发布。",
            -8:"禁止游客弹幕。",
            -9:"禁止滚动弹幕、顶端弹幕、底端弹幕超过100字符。",
            -101:"您的登录已经失效，请重新登录。",
            -102:"您需要激活账号后才可以发送弹幕。",
            -108:"您暂时失去了发送弹幕的权利，请与管理员联系。",
            -400:"登录信息验证失败，请刷新后重试。",
            -403:"您不能发送包含换行符的弹幕。",
            -404:"您不能向一个不存在的弹幕池发送弹幕。",
            -634:"禁止发送空白弹幕。",
            -635:"禁止向未审核的视频发送弹幕。",
            -636:"您发送弹幕的频率过快。",
            -637:"弹幕包含被禁止的内容。",
            -638:"您已经被禁言，不能发送弹幕。",
            -639:"您的权限不足，不能发送这种样式的弹幕。",
            -640:"您的节操低于60，不能发送弹幕。",
            -641:"您的弹幕长度大于100。",
            -651:"您的等级不足，不能发送彩色弹幕。",
            -653:"您的等级不足，不能发送高级弹幕。",
            -654:"您的等级不足，不能发送底端弹幕。",
            -655:"您的等级不足，不能发送顶端弹幕。",
            -656:"您的会员等级为Lv0，弹幕长度不能超过20字符。"
        ]
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
    public func post(danmaku: S2BDanmaku, toPage page: BKVideo.Page, completionHandler: PostCompletionHandler? = nil) {
        func emit() {
            tryPost(danmaku: danmaku, toPage: page) { result in
                switch result {
                case .success(posted: let posted):
                    completionHandler?(posted)
                case .refused(danmaku: let danmaku, message: let message, code: let code):
                    if code == -636 { // Frequency too high
                        emit()
                    } else {
                        fatalError("\(message): \(danmaku.content)")
                    }
                case .aborted:
                    emit()
                }
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
    public func post(subtitle: S2BSubtitle, toPage page: BKVideo.Page, configs: [S2BDanmaku.Config] = [.default], updateHandler: ProgressReportHandler? = nil, completionHandler: CompletionHandler? = nil) {
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
            post(danmaku: S2BDanmaku(danmaku, playTime: subtitle.startTime, config: config), toPage: page) { posted in
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
    public func post(srt: S2BSubRipFile, toPage page: BKVideo.Page, configs: [S2BDanmaku.Config] = [.default], updateHandler: ProgressReportHandler? = nil, completionHandler: CompletionHandler? = nil) {
        var subs = srt.subtitles
        guard subs.count > 0 else { completionHandler?([]);return }
        var progress = Progress(totalUnitCount: Int64(subs.count))
        var sub = subs.removeFirst()
        func emit() {
            progress.becomeCurrent(withPendingUnitCount: 1)
            post(subtitle: sub, toPage: page, configs: configs,
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
