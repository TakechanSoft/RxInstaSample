//
//  StorageModel.swift
//  RxInstaSample
//

import Firebase
import FirebaseStorageUI
import RxSwift


protocol StorageModelProtocol {
    func putImage(_ image: UIImage, fileName: String) -> Observable<Bool>
}

enum StorageModelError: Error {
    case unknown
}

class StorageModel : StorageModelProtocol {
    static public let shared = StorageModel()
    
    static let ImagePath = "images"

    func putImage(_ image: UIImage, fileName: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            // 画像をアップロードする
            let imageRef = Storage.storage().reference().child(Self.ImagePath).child(fileName)
            let imageData = image.jpegData(compressionQuality: 0.75)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                if let error = error {
                    // 画像のアップロード失敗
                    print(error)
                    observer.onError(error)
                    return
                }
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}

class StorageModelMock : StorageModelProtocol {
    static public let shared =  StorageModelMock()
    
    var putImageMock: ((_ image: UIImage, _ fileName: String) -> Observable<Bool>)?

    func putImage(_ image: UIImage, fileName: String) -> Observable<Bool> {
        return putImageMock!(image, fileName)
    }

}

extension UIImageView {
    func setStorageImage(fileName: String) {
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(StorageModel.ImagePath).child(fileName)
        self.sd_setImage(with: imageRef)

    }
}
