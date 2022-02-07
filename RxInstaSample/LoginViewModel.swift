//
//  LoginViewModel.swift
//  RxInstaSample
//

import RxSwift
import RxCocoa

class LoginViewModel {
    var userCreateValidation: Signal<Bool>
    var userCreateComplete: Signal<Bool>
    var userLoginValidation: Signal<Bool>
    var userLoginComplete: Signal<Bool>

    init(
        mailAddress: Driver<String>,
        password:  Driver<String>,
        displayName: Driver<String>,
        userCreateTap: Signal<Void>,
        userLoginTap: Signal<Void>,
        model:AuthModelProtocol
    ) {

        // ユーザー作成
        let userCreateData = Driver.combineLatest(mailAddress, password, displayName) {
            return (mailAddress: $0, password: $1, displayName: $2)
        }
        
        userCreateValidation = userCreateTap
            .withLatestFrom(userCreateData)
            .flatMapLatest { accountData in
                if accountData.mailAddress.isEmpty ||
                    accountData.password.isEmpty ||
                    accountData.displayName.isEmpty {
                    return Signal.just(false)
                }
                return Signal.just(true)
            }

        userCreateComplete = userCreateValidation
            .filter {vaidationSuccess in
                vaidationSuccess
            }
            .withLatestFrom(userCreateData)
            .flatMapLatest { accountData in
                model.createUser(
                    mailAddress: accountData.mailAddress,
                    password: accountData.password,
                    displayName: accountData.displayName
                ).asSignal(onErrorJustReturn: false)
            }

        // ユーザーログイン
        let userLoginData = Driver.combineLatest(mailAddress, password) {
            return (mailAddress: $0, password: $1)
        }
        
        userLoginValidation = userLoginTap
            .withLatestFrom(userLoginData)
            .flatMapLatest { accountData in
                if accountData.mailAddress.isEmpty ||
                    accountData.password.isEmpty {
                    return Signal.just(false)
                }
                return Signal.just(true)
            }
        
        userLoginComplete = userLoginValidation
            .filter { $0 == true }
            .withLatestFrom(userLoginData)
            .flatMapLatest { accountData in
                model.signIn(
                    mailAddress: accountData.mailAddress,
                    password: accountData.password
                ).asSignal(onErrorJustReturn: false)
            }
    }
}
