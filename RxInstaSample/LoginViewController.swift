//
//  LoginViewController.swift
//  RxInstaSample
//

import UIKit
import Firebase
import SVProgressHUD
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewModel生成
        let viewModel = LoginViewModel(
            mailAddress: mailAddressTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            displayName: displayNameTextField.rx.text.orEmpty.asDriver(),
            userCreateTap: createAccountButton.rx.tap.asSignal(),
            userLoginTap: loginButton.rx.tap.asSignal(),
            model: AuthModel.shared
        )
        
        // ユーザー作成
        viewModel.userCreateValidation
            .emit { success in
                if success {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.userCreateComplete
            .emit { success in
                if success {
                    SVProgressHUD.dismiss()
                    self.dismiss(animated: true)
                } else {
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                }
            }
            .disposed(by: disposeBag)
        
        // ユーザーログイン
        viewModel.userLoginValidation
            .emit { success in
                if success {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.userLoginComplete
            .emit { success in
                if success {
                    SVProgressHUD.dismiss()
                    self.dismiss(animated: true)
                } else {
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました。")
                }
            }
            .disposed(by: disposeBag)
        
    }
}
