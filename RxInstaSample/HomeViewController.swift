//
//  HomeViewController.swift
//  RxInstaSample
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        let likeButtonRelay = PublishRelay<PostDataProtocol>()
        
        // ViewModel生成
        let viewModel = HomeViewModel(
            likeButtonTap: likeButtonRelay.asSignal(),
            databaseModel: DatabaseModel.shared
        )
        
        // postsをTableViewに表示
        viewModel.posts
            .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: PostTableViewCell.self)) { row, postData, cell in
                // セルにデータを設定
                cell.setPostData(postData)
                // いいねボタンが押された時の処理
                cell.likeButton.rx.tap.asSignal()
                    .emit(onNext: {
                        likeButtonRelay.accept(postData)
                    }).disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        // いいね処理完了イベントは受け取って廃棄する(受け取らないといいねボタンのイベントが発生しない)
        viewModel.likeComplete.emit().disposed(by: disposeBag)
        
    }

}
