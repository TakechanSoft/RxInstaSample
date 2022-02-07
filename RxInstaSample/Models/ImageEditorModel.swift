//
//  ImageEditorModel.swift
//  RxInstaSample
//

import UIKit
import CLImageEditor
import RxSwift

protocol ImageEditorModelProtocol {
    init(viewController: UIViewController)
    func editImage(image: UIImage) -> Observable<Void>
}

enum ImageEditorModelError: Error {
    case notSupported
    case unknown
}

class ImageEditorModel : ImageEditorModelProtocol {
    
    var viewController: UIViewController
    
    var editor = CLImageEditorClosureWrapper()
    
    required init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func editImage(image: UIImage) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] observer in
            editor.editImage(
                image: image,
                from: viewController,
                didFinish: { editor, image in
                    observer.onNext(())
                    observer.onCompleted()
                    // PostViewControllerからeditorに戻って再編集できるようにするため
                    // ここから続けてPostViewControllerに画面遷移する
                    let storyboard = UIStoryboard(name: "PostViewController", bundle: nil)
                    let postViewController = storyboard.instantiateInitialViewController() as! PostViewController
                    postViewController.image = image
                    editor.present(postViewController, animated: true)
                    
                },
                didCancel: {editor in
                    observer.onCompleted()
                })
            return Disposables.create()
        }
    }
    
}

class CLImageEditorClosureWrapper: NSObject, CLImageEditorDelegate {
    var didFinish : ((CLImageEditor, UIImage)->())?
    var didCancel : ((CLImageEditor)->())?
    func editImage(image: UIImage,
                   from viewController: UIViewController,
                   didFinish: ((CLImageEditor, UIImage)->())? = nil,
                   didCancel: ((CLImageEditor)->())? = nil)
    {
        self.didFinish = didFinish
        self.didCancel = didCancel
        let editor = CLImageEditor(image: image)!
        editor.delegate = self
        viewController.present(editor, animated: true, completion: nil)
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        didFinish?(editor, image)
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: true)
        didCancel?(editor)
    }
    
}

class ImageEditorModelMock : ImageEditorModelProtocol {
    var editImageMock: ((_ image: UIImage) -> Observable<Void>)?
    
    required init(viewController: UIViewController) {
    }
    
    func editImage(image: UIImage) -> Observable<Void> {
        return editImageMock!(image)
    }
    
}
