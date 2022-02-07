//
//  PostViewModel.swift
//  RxInstaSample
//

import RxSwift
import RxCocoa

class PostViewModel {
    var image: Driver<UIImage>
    var postDataStart: Signal<Void>
    var putImageComplete: Signal<Bool>
    var postDataComplete: Signal<Bool>
    var closeScreen: Signal<Void>

    init(
        image: Driver<UIImage>,
        textFieldText: Driver<String>,
        postButtonTap: Signal<Void>,
        cancelButtonTap: Signal<Void>,
        authModel: AuthModelProtocol,
        databaseModel: DatabaseModelProtocol,
        storageModel: StorageModelProtocol
    ) {
        self.image = image
        
        postDataStart = postButtonTap
        
        let postID = databaseModel.newPostID

        putImageComplete = postButtonTap
            .withLatestFrom(image)
            .flatMapLatest { image in
                let fileName = postID + ".jpg"
                return storageModel.putImage(image, fileName: fileName)
                    .asSignal(onErrorJustReturn: false)
            }
        
        postDataComplete = putImageComplete
            .filter {$0 == true}
            .withLatestFrom(textFieldText)
            .flatMapLatest{ text in
                return databaseModel.saveData(postID: postID, title: text)
                    .asSignal(onErrorJustReturn: false)
            }
        
        closeScreen = cancelButtonTap
    }
    
}
