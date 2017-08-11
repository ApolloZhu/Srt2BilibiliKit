//
//  S2BDanmaku.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/8/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

/// Basic information of a local danmaku
public class S2BDanmaku {
    
    /// Initialize a danmaku with given content, cid to post to,
    /// time to display, and configurations.
    ///
    /// - Parameters:
    ///   - danmaku: content of the danmaku.
    ///   - cid: cid for the danmaku to post to.
    ///   - playTime: time to display the danmaku.
    ///   - config: configurations of the danmaku.
    public init(_ danmaku: String, cid: Int, playTime: TimeInterval, config: Config) {
        self.cid = cid
        self.content = danmaku
        self.playTime = playTime
        self.config = config
    }
    
    /// Initialize a danmaku with given content, cid to post to,
    /// time to display, and any of the configurations.
    ///
    /// - Parameters:
    ///   - danmaku: content of the danmaku.
    ///   - cid: cid for the danmaku to post to.
    ///   - playTime: time to display the danmaku.
    ///   - color: color of the danamku, in integer form.
    ///   - fontSize: font size of the danmaku.
    ///   - mode: mode/type of the danmaku.
    ///   - pool: pool for the danmaku to post to.
    public convenience init(_ danmaku: String, cid: Int, playTime: TimeInterval, rgb color: Int? = nil, fontSize: Config.FontSize? = nil, mode: Config.Mode? = nil, pool: Config.Pool? = nil) {
        self.init(danmaku, cid: cid, playTime: playTime,
                  config: Config(rgb: color, fontSize: fontSize, mode: mode, pool: pool))
    }
    
    /// CID of the video to post to
    public let cid: Int
    /// Content of the danmaku
    public let content: String
    /// When the danmaku should appear
    public let playTime: TimeInterval
    /// Configurations of the danmaku
    public let config: Config
    
    /// Danmaku Configurations.
    public struct Config {
        /// Color of the danamku.
        public let color: Int
        /// Font size of the danmaku.
        public let fontSize: FontSize
        /// Mode of the danamaku.
        public let mode: Mode
        /// Pool for the danmaku to post to.
        public let pool: Pool
        
        /// Default configuration.
        public static let `default` = Config()
        
        /// Initialize a configuration for danmaku.
        ///
        /// - Parameters:
        ///   - color: color of the danmaku.
        ///   - fontSize: font size of the danmaku.
        ///   - mode: mode of the danmaku.
        ///   - pool: pool for the danmaku to post to.
        public init(rgb color: Int? = nil, fontSize: FontSize? = nil, mode: Mode? = nil, pool: Pool? = nil) {
            self.color = max(min(color ?? 0xFFFFFF, 0xFFFFFF), 0)
            self.fontSize = fontSize ?? .medium
            self.mode = mode ?? .bottom
            self.pool = pool ?? .normal
        }
        
        /// Mode/Type of the danmaku.
        ///
        /// - normal: 滚动弹幕 (rolling) on bilibili.
        /// - bottom: 底部弹幕 on bilibili.
        /// - top: 顶部弹幕 on bilibili.
        /// - reversed: 逆向弹幕 on bilibili.
        /// - special: 特殊弹幕 on bilibili.
        /// - advanced: 高级弹幕 on bilibili.
        public enum Mode: Int {
            /// 滚动弹幕 (rolling) on bilibili.
            case normal = 1
            /// 底部弹幕 on bilibili.
            case bottom = 4
            /// 顶部弹幕 on bilibili.
            case top = 5
            /// 逆向弹幕 on bilibili.
            case reversed = 6
            /// 特殊弹幕 on bilibili.
            case special = 7
            /// 高级弹幕 on bilibili.
            case advanced = 9
        }
        
        /// Pool for the danmaku to post to.
        ///
        /// - normal: 普通弹幕 on bilibili.
        /// - subtitle: requires the emitter must own the video.
        ///             字幕弹幕（要求发送者拥有视频的所有权）on bilibili.
        /// - special: 特殊弹幕 on bilibili.
        public enum Pool: Int {
            /// See class reference.
            case normal = 0, subtitle, special
        }
        
        /// Wrapper for font size of the danmaku.
        ///
        /// - small: "小" on bilibili.
        /// - medium: "中" on bilibili.
        /// - large: "大" on bilibili.
        /// - custom: Some user defined value.
        /// - FontSize.small.rawValue:: 18.
        /// - FontSize.medium.rawValue:: 25.
        /// - FontSize.large.rawValue:: 36.
        public enum FontSize: RawRepresentable {
            /// See class reference.
            case small, medium, large
            /// Some user defined font size.
            case custom(Int)
            
            public typealias RawType = Int
            
            /// Actual font size.
            public var rawValue: Int {
                switch self {
                case .small:
                    return 18
                case .medium:
                    return 25
                case .large:
                    return 36
                case .custom(let fontSize):
                    return fontSize
                }
            }
            
            /// Initialize a FontSize of given point.
            ///
            /// - Parameter rawValue: font size.
            public init?(rawValue: Int) {
                switch rawValue {
                case FontSize.small.rawValue:
                    self = .small
                case FontSize.medium.rawValue:
                    self = .medium
                case FontSize.large.rawValue:
                    self = .large
                default:
                    self = .custom(rawValue)
                }
            }
        }
    }
}
