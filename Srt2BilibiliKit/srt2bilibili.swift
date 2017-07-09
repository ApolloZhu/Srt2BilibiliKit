//
//  Bilibili.swift
//  srt2bilibili
//
//  Created by Apollo Zhu on 7/8/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

struct S2BCookie: CustomStringConvertible {
    let DedeUserID: Int = 14767902
    let DedeUserID__ckMd5: String = "ed080b017d2a47c6"
    let SESSDATA: String = "5b29fa37%2C1500285664%2C896c2fc1"
    var description: String {
        return "DedeUserID=\(DedeUserID);DedeUserID__ckMd5=\(DedeUserID__ckMd5);SESSDATA=\(SESSDATA)"
    }
}

struct S2BVideoPart: Codable {
    let page: Int
    let pageName: String
    let cid: Int

    enum CodingKeys: String, CodingKey {
        case page, cid
        case pageName = "pagename"
    }
}

func cids(fromAID aid: Int, process: @escaping ((_ page: [S2BVideoPart]?) -> Void)) {
    URLSession.shared.dataTask(with: URL(string: "http://www.bilibili.com/widget/getPageList?aid=\(aid)")!) { (data, _, _) in
        guard let data = data, let list = try? JSONDecoder().decode([S2BVideoPart].self, from: data) else { return process(nil) }
        process(list)
        }.resume()
}

func cid(fromAID aid: Int, page: Int = 1, process: @escaping ((_ page: S2BVideoPart?) -> Void)) {
    let page = abs(page)
    cids(fromAID: aid) {
        guard let list = $0, list.count >= page else { return process(nil) }
        process(list[page - 1])
    }
}

extension S2BDanmuku: CustomStringConvertible {
    public var description: String {
        let random = Int(arc4random_uniform(100000))
        let date: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: Date())
        }()
        return "fontsize=\(fontSize.rawValue)&message=\(content)&mode=\(mode.rawValue)&pool=\(pool.rawValue)&color=\(color)&date=\(date)&rnd=\(random)&playTime=\(playTime)&cid=\(cid)"
    }
}

/*
 headers = {'Origin': 'http://static.hdslb.com', 'X-Requested-With': 'ShockwaveFlash/15.0.0.223', 'Referer': 'http://static.hdslb.com/play.swf', 'User-Agent': BILIGRAB_UA, 'Host': 'interface.bilibili.com', 'Content-Type': 'application/x-www-form-urlencoded'}
 #print(headers)
 payload = {'fontsize': fontsize, 'message': message, 'mode': mode, 'pool': pool, 'color': color, 'date': getdate(), 'rnd': rnd, 'playTime': playTime, 'cid': cid}
 try:
 r = requests.post(url, data = payload, headers = headers, cookies=cookie)
 */

func post(danmuku: S2BDanmuku, completionHandler: @escaping () -> Void) {
    var request = URLRequest(url: URL(string: "http://interface.bilibili.com/dmpost")!)
    request.allHTTPHeaderFields = ["Cookie": S2BCookie().description]
    request.httpBody = danmuku.description.data(using: .utf8)
    request.httpMethod = "POST"
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let data = data, let content = String(data: data, encoding: .utf8), content != "0" {
            print(data, content, error)
            print(danmuku.content)
            DispatchQueue.global().asyncAfter(deadline: .now() + 4, execute: {
                completionHandler()
            })
        } else {
            print("RETRY: \(danmuku.content)")
            DispatchQueue.global().asyncAfter(deadline: .now() + 4, execute: {
                post(danmuku: danmuku, completionHandler: completionHandler)
            })
        }
    }
    task.resume()
}
