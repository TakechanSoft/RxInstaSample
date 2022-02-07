//
//  HomeViewModel.swift
//  RxInstaSample
//

import RxSwift
import RxCocoa

class HomeViewModel {
    var posts: Driver<[PostDataProtocol]>
    var likeComplete: Signal<Bool>

    init(
        likeButtonTap: Signal<PostDataProtocol>,
        databaseModel: DatabaseModelProtocol
    ) {
        // 投稿一覧
        posts = databaseModel.posts.asDriver(onErrorJustReturn: [])
        
        // いいねボタンの処理
        likeComplete = likeButtonTap
            .flatMapLatest { postData in
                databaseModel.toggleLikes(postData: postData)
                    .asSignal(onErrorJustReturn: false)
            }
        
    }
}
