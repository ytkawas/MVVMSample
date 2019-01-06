//
//  CPSearchEventsApiModel.swift
//  MVVMSample
//
//  Created by pro on 2018/12/14.
//  Copyright © 2018年 ykawas. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

final class CPSearchEventsApiModel {
    func searchEvents(word: String) -> Observable<Events?> {
        return Observable.create { observer in
            let url = "https://connpass.com/api/v1/event/?keyword=\(word)"
            Alamofire.request(url, method: .get, parameters: nil)
                .responseJSON(completionHandler:{response in
                    switch response.result {
                    case .success(_):
                        print("API SUCCESS\n")
                        if let data = response.data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            if let result = try? decoder.decode(Events.self, from: data) {
                                print(result)
                                observer.onNext(result)
                            }
                        }
                        observer.onCompleted()
                    case .failure(let error):
                        print("API FAILURE\n")
                        print(error)
                        observer.onError(error)
                    }
                })
            return Disposables.create()
        }
    }
}

struct Events: Codable {
    let events: [Event]?
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        events = try values.decodeIfPresent([Event].self, forKey: .events)
    }
}

struct Event: Codable {
    let title: String?
    let startedAt: String?
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        startedAt = try values.decodeIfPresent(String.self, forKey: .startedAt)
    }
}
