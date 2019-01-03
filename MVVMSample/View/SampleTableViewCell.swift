//
//  SampleTableViewCell.swift
//  MVVMSample
//
//  Created by pro on 2018/12/10.
//  Copyright © 2018年 ykawas. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SampleTableViewCell: UITableViewCell {
    private let viewModel: SampleViewModel = SampleViewModel()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var startedAtLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // フォーマットされた日付をlabelにバインドする
        viewModel.formattedDate
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(startedAtLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func configure(_ event:Event) {
        if let title = event.title {
            titleLabel.text = title
        }
        
        // 日付のフォーマットを行うためにviewModelへストリームを流す
        Observable.from(optional: event.startedAt)
            .subscribe(viewModel.startedAt)
            .disposed(by: disposeBag)
    }
}
