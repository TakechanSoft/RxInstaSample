//
//  SettingViewModel.swift
//  RxInstaSample
//

import RxSwift
import RxCocoa

class SettingViewModel {
    var displayName: Driver<String>
    var changeDisplayNameValidation: Signal<Bool>
    var changeDisplayNameComplete: Signal<Bool>
    var userLogoutComplete: Signal<Bool>

    init(
        displayNameText: Driver<String>,
        changeDisplayNameTap: Signal<Void>,
        userLogoutTap: Signal<Void>,
        model: AuthModelProtocol
    ) {
        // ユーザー名
        self.displayName = model.displayName.asDriver(onErrorJustReturn: "")
        
        // ユーザー名変更
        changeDisplayNameValidation = changeDisplayNameTap
            .withLatestFrom(displayNameText)
            .flatMapLatest { displayName in
                if displayName.isEmpty {
                    return Signal.just(false)
                }
                return Signal.just(true)
            }

        changeDisplayNameComplete = changeDisplayNameValidation
            .filter { $0 == true }
            .withLatestFrom(displayNameText)
            .flatMapLatest { displayName in
                model.changeDisplayName(displayName: displayName)
                    .asSignal(onErrorJustReturn: false)
            }

        // ユーザーログアウト
        userLogoutComplete = userLogoutTap
            .flatMapLatest {
                model.signOut().asSignal(onErrorJustReturn: false)
            }
    }
}
