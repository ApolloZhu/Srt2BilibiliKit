//
//  S2BVideo.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

/// Bilibili video, identified by unique av number (aid).
public struct S2BVideo {
    
    /// AV number, the unique identifier of the video
    public let aid: Int
    
    /// Initialize a S2BVideo with its av number
    ///
    /// - Parameter aid: av number of the video
    public init(av aid: Int) {
        self.aid = aid
    }
    
    /// Sub page of video, identified by unique cid.
    public struct Page: Codable {
        /// Index of the page
        public let page: Int
        /// Name of the page
        public let pageName: String
        /// Unique identifier of the page
        public let cid: Int
        
        /// Coding keys to use when encoding to other formats
        ///
        /// - page: page
        /// - cid: cid
        /// - pageName: pagename
        enum CodingKeys: String, CodingKey {
            case page, cid
            case pageName = "pagename"
        }
    }
    
    /// Handler type for all pages fetched.
    ///
    /// - Parameter pages: pages fetched, nil if failed or the video has no sub pages.
    public typealias PagesHandler = (_ pages: [Page]?) -> Void
    
    /// Fetch all pages of video and perform action over.
    ///
    /// - Parameter code: code to perform on the pages.
    public func pages(code: @escaping PagesHandler) {
        S2B.kit.urlSession.dataTask(with: URL(string: "http://www.bilibili.com/widget/getPageList?aid=\(aid)")!) { (data, _, _) in
            guard let data = data, let pages = try? JSONDecoder().decode([Page].self, from: data), pages.count > 0 else { return code(nil) }
            code(pages)
            }.resume()
    }
    
    /// Handler type for single page fetched.
    ///
    /// - Parameter page: page fetched, nil if failed.
    public typealias PageHandler = (_ page: Page?) -> Void
    
    /// Fetch the first page of video and perform action over.
    ///
    /// - Parameter code: code to perform on the page.
    public func p1(code: @escaping PageHandler) {
        pages { code($0?.first) }
    }
    
    /// Fetch page of video at index and perform action over.
    ///
    /// - Parameters:
    ///   - index: **ONE** based index of the page to fetch.
    ///   - code: code to perform on the page.
    public func page(_ index: Int, code: @escaping PageHandler) {
        guard index > 0 else { return code(nil) }
        pages {
            guard let pages = $0, index <= pages.count else { return code(nil) }
            code(pages[index - 1])
        }
    }
    
    /// Fetch page of video at index and perform action over.
    ///
    /// - Parameters:
    ///   - index: **ZERO** based index of the page to fetch.
    ///   - code: code to perform on the page.
    public subscript(index: Int, code: @escaping PageHandler) -> Void {
        get {
            page(index + 1, code: code)
        }
    }
}

extension S2BVideo: Equatable {
    /// Check if two videos are the same.
    ///
    /// - Parameters:
    ///   - lhs: A video.
    ///   - rhs: Another video.
    /// - Returns: true if they have the same aid, false otherwise.
    public static func ==(lhs: S2BVideo, rhs: S2BVideo) -> Bool {
        return lhs.aid == rhs.aid
    }
}

extension S2BVideo.Page: Equatable {
    /// Check if two video pages are the same.
    ///
    /// - Parameters:
    ///   - lhs: A page of a video.
    ///   - rhs: Another page, of the same or another video.
    /// - Returns: true if they have the same cid, false otherwise.
    public static func ==(lhs: S2BVideo.Page, rhs: S2BVideo.Page) -> Bool {
        return lhs.cid == rhs.cid
    }
}
