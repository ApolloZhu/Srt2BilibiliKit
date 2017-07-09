//
//  S2BDanmuku.swift
//  srt2bilibili
//
//  Created by Apollo Zhu on 7/8/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

public struct S2BDanmuku {

    public let content: String
    public let cid: Int
    public let playTime: TimeInterval
    public let fontSize: FontSize
    public let color: Int
    public let mode: Mode
    public let pool: Pool

    public init(_ danmuku: String, cid: Int, playTime: TimeInterval, fontSize: FontSize = .medium, rgb: Int = 0xFFFFFF, mode: Mode = .bottom, pool: Pool = .subtitle) {
        self.content = danmuku
        self.cid = cid
        self.playTime = playTime
        self.fontSize = fontSize
        self.color = rgb
        self.mode = mode
        self.pool = pool
    }

    public enum Mode: Int {
        case normal = 1
        case bottom = 4
        case top = 5
        case reversed = 6
        case special = 7
        case advanced = 9
    }

    public enum Pool: Int {
        case normal = 0, subtitle, special
    }

    public enum FontSize {
        case small, medium, large
        case custom(Int)
    }
}

extension S2BDanmuku.FontSize: RawRepresentable {
    public typealias RawType = Int

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
        case S2BDanmuku.FontSize.small.rawValue:
            self = .small
        case S2BDanmuku.FontSize.medium.rawValue:
            self = .medium
        case S2BDanmuku.FontSize.large.rawValue:
            self = .large
        default:
            self = .custom(rawValue)
        }
    }
}
