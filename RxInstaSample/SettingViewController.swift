//
//  SettingViewController.swift
//  RxInstaSample
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var changeDisplayNameButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewModel生成
        let viewModel = SettingViewModel(
            displayNameText: displayNameTextField.rx.text.orEmpty.asDriver(),
            changeDisplayNameTap: changeDisplayNameButton.rx.tap.asSignal(),
            userLogoutTap: logoutButton.rx.tap.asSignal(),
            model: AuthModel.shared)
        
        // ユーザー名表示
        viewModel.displayName.drive(displayNameTextField.rx.text)
            .disposed(by: disposeBag)

        // ユーザー名変更
        viewModel.changeDisplayNameValidation
            .emit { success in
                if success {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                }
            }
            .disposed(by: disposeBag)
        viewModel.changeDisplayNameComplete
            .emit { success in
                if success {
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                } else {
                    SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                }
            }
            .disposed(by: disposeBag)
        
        // ユーザーログアウト
        viewModel.userLogoutComplete
            .emit { [unowned self] success in
                if success {
                    // ログイン画面を表示する
                    let storyboard = UIStoryboard(name: "LoginViewController", bundle: nil)
                    let loginViewController = storyboard.instantiateInitialViewController()!
                    present(loginViewController, animated: true)
                    
                    // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
                    tabBarController?.selectedIndex = 0
                }
            }
            .disposed(by: disposeBag)
    }
}
