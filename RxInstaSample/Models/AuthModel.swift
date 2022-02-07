//
//  AuthModel.swift
//  RxInstaSample
//

import Firebase
import RxSwift


protocol AuthModelProtocol {
    var hasLogin: Bool { get }
    var loginUserID: String { get }
    var loginUserName: String { get }
    func createUser(mailAddress: String, password: String, displayName: String) -> Observable<Bool>
    func signIn(mailAddress: String, password: String) -> Observable<Bool>
    var displayName: Observable<String> { get }
    func changeDisplayName(displayName: String) -> Observable<Bool>
    func signOut() -> Observable<Bool>

}

enum AuthModelError: Error {
    case notLogin
    case unknown
}

class AuthModel : AuthModelProtocol {
    static let shared = AuthModel()
    
    private var _displayName = BehaviorSubject<String>(value: Auth.auth().currentUser?.displayName ?? "")
    
    var hasLogin: Bool {
        Auth.auth().currentUser != nil
    }

    var loginUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    var loginUserName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }

    func createUser(mailAddress: String, password: String, displayName: String) -> Observable<Bool> {
        return Observable<Bool>.create { [unowned self] observer in
            Auth.auth().createUser(withEmail: mailAddress, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let user = Auth.auth().currentUser {
                        let req = user.createProfileChangeRequest()
                        req.displayName = displayName
                        req.commitChanges { error in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                observer.onNext(true)
                                observer.onCompleted()
                                _displayName.onNext(Auth.auth().currentUser?.displayName ?? "")
                                DatabaseModel.shared.startPostsListener()
                            }
                        }
                    } else {
                        observer.onError(AuthModelError.unknown)
                    }
                }
            }
            return Disposables.create()
        }
    }

    func signIn(mailAddress: String, password: String) -> Observable<Bool> {
        return Observable<Bool>.create { [unowned self] observer in
            Auth.auth().signIn(withEmail: mailAddress, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(true)
                    observer.onCompleted()
                    _displayName.onNext(Auth.auth().currentUser?.displayName ?? "")
                    DatabaseModel.shared.startPostsListener()
                }
            }
            return Disposables.create()
        }
    }
    
    var displayName: Observable<String> {
        return _displayName.asObservable()
    }
    
    func changeDisplayName(displayName: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            if let user = Auth.auth().currentUser {
                let req = user.createProfileChangeRequest()
                req.displayName = displayName
                req.commitChanges { error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                        
                    }
                }
            } else {
                observer.onError(AuthModelError.notLogin)
            }
            return Disposables.create()
        }
    }
    
    func signOut() -> Observable<Bool> {
        DatabaseModel.shared.stopPostsListener()
        try! Auth.auth().signOut()
        return Observable<Bool>.create { observer in
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }

}


class AuthModelMock : AuthModelProtocol {
    static let shared =  AuthModelMock()
    
    var hasLoginMock: (() ->Bool)?
    var loginUserIDMock: (() ->String)?
    var loginUserNameMock: (() ->String)?
    var createUserMock: ((_ mailAddress: String, _ password: String, _ displayName: String) -> Observable<Bool>)?
    var signInMock: ((_ mailAddress: String, _ password: String) -> Observable<Bool>)?
    var displayNameMock: (() ->Observable<String>)?
    var changeDisplayNameMock: ((_ displayName: String) -> Observable<Bool>)?
    var signOutMock: (() -> Observable<Bool>)?

    var hasLogin: Bool {
        return hasLoginMock!()
    }
    
    var loginUserID: String {
        return loginUserIDMock!()
    }
    
    var loginUserName: String {
        return loginUserNameMock!()
    }
    
    func createUser(mailAddress: String, password: String, displayName: String) -> Observable<Bool> {
        return createUserMock!(mailAddress, password, displayName)
    }

    func signIn(mailAddress: String, password: String) -> Observable<Bool> {
        return signInMock!(mailAddress, password)
    }
    
    var displayName: Observable<String> {
        return displayNameMock!()
    }
    
    func changeDisplayName(displayName: String) -> Observable<Bool> {
        return changeDisplayNameMock!(displayName)
    }
    
    func signOut() -> Observable<Bool> {
        return signOutMock!()
    }

}
