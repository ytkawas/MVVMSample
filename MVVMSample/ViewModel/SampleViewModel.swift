//
//  SampleViewModel.swift
//  MVVMSample
//
//  Created by pro on 2018/12/11.
//  Copyright © 2018年 ykawas. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SampleViewModel {
    private let disposeBag = DisposeBag()
    
    private let searchWordStream = PublishSubject<String>()
    private let eventsStream = PublishSubject<Events>()
    
    private let startedAtStream = PublishSubject<String>()
    private let formattedDateStream = PublishSubject<String>()
    
    init() {
        searchWordStream.flatMapLatest{word -> Observable<Events> in
            print("searchWord:\(word)")
            let model = CPSearchEventsApiModel()
            return  model.searchEvents(word: word)
        }
        .subscribe(eventsStream)
        .disposed(by: disposeBag)
        
        startedAtStream.flatMapLatest{st -> Observable<String> in
            return self.format(dateString: st)
        }
        .subscribe(formattedDateStream)
        .disposed(by: disposeBag)
    }
    
    func format(dateString: String) -> Observable<String> {
        return Observable.create { observer in
            let iso8601DateFormatter = ISO8601DateFormatter()
            let date = iso8601DateFormatter.date(from: dateString)
            if let date = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM(EEE)", options: 0, locale: Locale(identifier: "ja_JP"))
                let result = dateFormatter.string(from: date)
                observer.onNext(result)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

// MARK: Observer

extension SampleViewModel {
    var searchWord: AnyObserver<(String)> {
        return searchWordStream.asObserver()
    }
    var startedAt: AnyObserver<String> {
        return startedAtStream.asObserver()
    }
}

// MARK: Observable

extension SampleViewModel {
    var events: Observable<Events> {
        return eventsStream.asObservable()
    }
    var formattedDate: Observable<String> {
        return formattedDateStream.asObservable()
    }
}
