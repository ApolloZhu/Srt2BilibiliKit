//
//  S2B.swift
//  Srt2BilibiliKit
//
//  Created by Apollo Zhu on 7/13/17.
//

#if os(Linux) || os(Android) || os(Windows)
    import Glibc
#endif
import Foundation

/// Container for global stuff
struct S2B {
    /// Entry point
    public static let `kit` = S2B()
    
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
    func random(max: Int = 100000) -> Int {
        #if os(Linux) || os(Android) || os(Windows)
            return Glibc.random() % max
        #else
            return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
    
    #if os(Linux) || os(Android) || os(Windows)
    /// Shared url session, replacement for URLSession.shared
    let urlSession = URLSession(configuration: .default)
    #else
    /// Shared url session, alias of URLSession.shared
    var urlSession: URLSession { return URLSession.shared }
    #endif
    
}
