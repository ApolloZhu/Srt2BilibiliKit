import XCTest
@testable import Srt2BilibiliKit
import Dispatch

class Srt2BilibiliKitTests: XCTestCase {

    func testVideoPageFetching() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let goal = expectation(description: "Video page information fetch")
        S2BVideo(av: 8993458).p1 { page in
            XCTAssertNotNil(page, "Failed to fetch pages of video")
            XCTAssertEqual(page!.cid, 14848859, "Wrong cid")
            goal.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }

    func testAllDanmakuFetching() {
        let goal = expectation(description: "Video danmaku fetch")
        S2BPostedDanmaku.allDanmaku(ofCID: 14848859) {
            XCTAssertNotEqual($0.count, 0, "No danmaku fetched")
            print($0)
            goal.fulfill()
        }
        waitForExpectations(timeout: 150, handler: nil)
    }

    static let allTests = [
        ("testVideoPageFetching", testVideoPageFetching)
    ]
}
