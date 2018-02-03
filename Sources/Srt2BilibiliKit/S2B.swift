//
//  S2B.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/13/17.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
#else
// UNSUPPORTED: OS=macosx
// UNSUPPORTED: OS=ios
// UNSUPPORTED: OS=tvos
// UNSUPPORTED: OS=watchos
// UNSUPPORTED: OS=linux-androideabi
// https://github.com/apple/swift/blob/master/validation-test/stdlib/Glibc.swift
import Glibc
#endif

import Foundation

/// Container for global stuff
struct S2B {
    /// Entry point
    public static let kit = S2B()
    
    /// Container for "top level code"
    private init() {
        #if os(Linux) || os(Android) || os(Windows)
        srand(UInt32(time(nil)))
        #endif
    }
    
    /// Cross platform random int generator
    ///
    /// - Parameter max: exclusive upper bound for generated int
    /// - Returns: a random integer in range 0..<max
    private func randomInt(lessThan max: Int) -> Int {
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        return Int(arc4random_uniform(UInt32(max)))
        #else
        return Glibc.random() % max
        #endif
    }
    
    /// Should be identical for the same bilibili-player by this formula:
    /// 1E3 * (new Date).getTime() + Math.floor(900 * Math.random()) + 100
    var random: Int {
        return 1000 * (Int(Date().timeIntervalSince1970 * 1000) + randomInt(lessThan: 900)) + 100
    }
    
    #if os(Linux) || os(Android) || os(Windows)
    /// Shared url session, replacement for URLSession.shared
    let urlSession = URLSession(configuration: .default)
    #else
    /// Shared url session, alias of URLSession.shared
    var urlSession: URLSession { return URLSession.shared }
    #endif
    
}
