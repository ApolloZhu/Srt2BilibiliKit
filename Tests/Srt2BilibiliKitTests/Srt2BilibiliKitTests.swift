import XCTest
@testable import Srt2BilibiliKit
import Dispatch

class Srt2BilibiliKitTests: XCTestCase {
    func testAllDanmakuFetching() {
        let goal = expectation(description: "Video danmaku fetch")
        S2BPostedDanmaku.allDanmaku(ofCID: 14848859) {
            XCTAssertNotEqual($0.count, 0, "No danmaku fetched")
            print($0)
            goal.fulfill()
        }
        waitForExpectations(timeout: 150, handler: nil)
    }

    static let allTests: [String, (Srt2BilibiliKitTests) -> () -> Void] = []
    ]
}
