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
    
    public init(_ danmaku: String, cid: Int, playTime: TimeInterval, config: Config) {
        self.cid = cid
        self.content = danmaku
        self.playTime = playTime
        self.config = config
    }
    
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
    
    public struct Config {
        /// Color of the danamku
        public let color: Int
        /// Font size of the danmaku
        public let fontSize: FontSize
        /// Mode of the danamaku
        public let mode: Mode
        /// Pool for the danmaku to post to
        public let pool: Pool
        
        /// Default configuration
        public static let `default` = Config()
        
        /// Initialize a configuration for danmaku
        ///
        /// - Parameters:
        ///   - color: color of the danmaku
        ///   - fontSize: font size of the danmaku
        ///   - mode: mode of the danmaku
        ///   - pool: pool for the danmaku to post to
        public init(rgb color: Int? = nil, fontSize: FontSize? = nil, mode: Mode? = nil, pool: Pool? = nil) {
            self.color = max(min(color ?? 0xFFFFFF, 0xFFFFFF), 0)
            self.fontSize = fontSize ?? .medium
            self.mode = mode ?? .bottom
            self.pool = pool ?? .normal
        }
        
        /// Mode/Type of the danmaku
        ///
        /// - normal: 滚动弹幕 (rolling) on bilibili
        /// - bottom: 底部弹幕 on bilibili
        /// - top: 顶部弹幕 on bilibili
        /// - reversed: 逆向弹幕 on bilibili
        /// - special: 特殊弹幕 on bilibili
        /// - advanced: 高级弹幕 on bilibili
        public enum Mode: Int {
            case normal = 1
            case bottom = 4
            case top = 5
            case reversed = 6
            case special = 7
            case advanced = 9
        }
        
        /// Pool for the danmaku to post to
        ///
        /// - normal: 普通弹幕 on bilibili
        /// - subtitle: requires the emitter must own the video
        ///             字幕弹幕（要求发送者拥有视频的所有权）on bilibili
        /// - special: 特殊弹幕 on bilibili
        public enum Pool: Int {
            case normal = 0, subtitle, special
        }
        
        /// Wrapper for font size of the danmaku
        ///
        /// - small: "小" on bilibili
        /// - medium: "中" on bilibili
        /// - large: "大" on bilibili
        /// - custom: Some user defined value
        /// - FontSize.small.rawValue:: 18
        /// - FontSize.medium.rawValue:: 25
        /// - FontSize.large.rawValue:: 36
        public enum FontSize: RawRepresentable {
            case small, medium, large
            case custom(Int)
            
            public typealias RawType = Int
            
            /// Actual font size
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
