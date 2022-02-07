//
//  ImageViewController.swift
//  RxInstaSample
//

import UIKit
import RxSwift
import RxCocoa

class ImageViewController: UIViewController {
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewModel生成
        let viewModel = ImageViewModel(
            libraryButtonTap: libraryButton.rx.tap.asSignal(),
            cameraButtonTap: cameraButton.rx.tap.asSignal(),
            cancelButtonTap: cancelButton.rx.tap.asSignal(),
            imagePickerModel: ImagePickerModel(viewController: self),
            imageEditorModel: ImageEditorModel(viewController: self)
        )
        
        // 画像投稿完了イベントは受け取って廃棄する(受け取らないとイベントが発生しない)
        viewModel.postImageComplete.emit().disposed(by: disposeBag)
        
        // キャンセルボタンは画面を閉じる
        viewModel.closeScreen
            .emit(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
