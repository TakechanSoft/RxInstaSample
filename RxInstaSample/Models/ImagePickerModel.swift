//
//  ImagePickerModel.swift
//  RxInstaSample
//

import UIKit
import RxSwift

protocol ImagePickerModelProtocol {
    init(viewController: UIViewController)
    func pickImage(type: UIImagePickerController.SourceType) -> Observable<UIImage>
}

enum ImagePickerModelError: Error {
    case notSupported
    case unknown
}

class ImagePickerModel : ImagePickerModelProtocol {

    var viewController: UIViewController

    var picker = UIImagePickerControllerClosureWrapper()
    
    required init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func pickImage(type: UIImagePickerController.SourceType) -> Observable<UIImage> {
        return Observable<UIImage>.create { [unowned self] observer in
            if UIImagePickerController.isSourceTypeAvailable(type) {
                picker.pickImage(
                    type: type,
                    from: viewController,
                    didFinish: { picker, info in
                        if info[.originalImage] != nil {
                            // 撮影/選択された画像を取得する
                            let image = info[.originalImage] as! UIImage
                            observer.onNext(image)
                            observer.onCompleted()
                        } else {
                            observer.onCompleted()
                        }
                    },
                    didCancel: {picker in
                        observer.onCompleted()
                    })
            } else {
                observer.onError(ImagePickerModelError.unknown)
            }
            return Disposables.create()
        }
    }
    
}

class UIImagePickerControllerClosureWrapper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var didFinish : ((UIImagePickerController, [UIImagePickerController.InfoKey : Any])->())?
    var didCancel : ((UIImagePickerController)->())?
    func pickImage(type: UIImagePickerController.SourceType,
                   from viewController: UIViewController,
                   didFinish: ((UIImagePickerController, [UIImagePickerController.InfoKey : Any])->())? = nil,
                   didCancel: ((UIImagePickerController)->())? = nil)
    {
        self.didFinish = didFinish
        self.didCancel = didCancel
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        viewController.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        didFinish?(picker, info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        didCancel?(picker)
    }
    
}

class ImagePickerModelMock : ImagePickerModelProtocol {
    
    var pickImageMock: ((_ type: UIImagePickerController.SourceType) -> Observable<UIImage>)?
    
    required init(viewController: UIViewController) {
    }
    
    func pickImage(type: UIImagePickerController.SourceType) -> Observable<UIImage> {
        return pickImageMock!(type)
    }
    
}
