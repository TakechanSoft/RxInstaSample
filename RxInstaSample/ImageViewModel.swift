//
//  ImageSelectViewModel.swift
//  RxInstaSample
//

import RxSwift
import RxCocoa

class ImageViewModel {
    var postImageComplete: Signal<Void>
    var closeScreen: Signal<Void>

    init(
        libraryButtonTap: Signal<Void>,
        cameraButtonTap: Signal<Void>,
        cancelButtonTap: Signal<Void>,
        imagePickerModel: ImagePickerModelProtocol,
        imageEditorModel: ImageEditorModelProtocol
    ) {
        let pickedLibraryImage =  libraryButtonTap
            .flatMapLatest {
                return imagePickerModel.pickImage(type: .photoLibrary)
                    .asSignal(onErrorJustReturn: UIImage())
            }
        
        let cameraShotImage = cameraButtonTap
            .flatMapLatest {
                return imagePickerModel.pickImage(type: .camera)
                    .asSignal(onErrorJustReturn: UIImage())
            }
        
        let pickedImage = Signal.merge(pickedLibraryImage, cameraShotImage)

        postImageComplete = pickedImage
            .flatMapLatest({ image in
                // imageEditorを呼び出し、imageEditorからPostViewControllerに画面遷移して投稿する
                return imageEditorModel.editImage(image: image)
                    .asSignal(onErrorJustReturn: ())
            })
        
        closeScreen = cancelButtonTap
    }

}
