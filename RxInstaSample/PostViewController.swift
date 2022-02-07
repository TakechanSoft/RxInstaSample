//
//  PostViewController.swift
//  RxInstaSample
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

class PostViewController: UIViewController {
    var image: UIImage!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageRelay = BehaviorRelay(value: image!)
        
        // viewModel生成
        let viewModel = PostViewModel(
            image: imageRelay.asDriver(),
            textFieldText: textField.rx.text.orEmpty.asDriver(),
            postButtonTap: postButton.rx.tap.asSignal(),
            cancelButtonTap: cancelButton.rx.tap.asSignal(),
            authModel: AuthModel.shared,
            databaseModel: DatabaseModel.shared,
            storageModel: StorageModel.shared
            )
        
        // imageをimageViewに表示
        viewModel.image.drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.postDataStart
            .emit (onNext: {
                SVProgressHUD.show()
            })
            .disposed(by: disposeBag)

        viewModel.putImageComplete
            .emit(onNext: { success in
                if success == false {
                    SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                }
            })
            .disposed(by: disposeBag)

        viewModel.postDataComplete
            .emit(onNext: { success in
                SVProgressHUD.showSuccess(withStatus: "投稿しました")
                // 投先頭画面に戻る
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.closeScreen
            .emit(onNext: {
                // 前の画面に戻る
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
