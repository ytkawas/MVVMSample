//
//  SampleTableViewController.swift
//  MVVMSample
//
//  Created by pro on 2018/12/07.
//  Copyright © 2018年 ykawas. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SampleTableViewController: UIViewController,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    private let viewModel: SampleViewModel = SampleViewModel()
    private var eventsDataSource: [Event]?
    private let disposeBag = DisposeBag()
    
    private let cellReuseId = "sampleCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "SampleTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseId)

        // テキストフィールドに入力されたワードをviewModelにバインド
        self.textField.rx.text.orEmpty
            .filter{$0.count >= 1}
            .debounce(0.5, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(viewModel.searchWord)
            .disposed(by: disposeBag)
        
        // イベントの検索結果のストリームを購読する
        viewModel.events
            .subscribe(onNext: {[weak self] events in
                self?.reloadData(events)
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadData(_ data:Events) {
        eventsDataSource = data.events
        tableView.reloadData()
    }
}

extension SampleTableViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = eventsDataSource {
            return events.count;
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = eventsDataSource![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as! SampleTableViewCell
        cell.configure(event)
        return cell
    }
}

