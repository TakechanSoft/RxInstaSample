//
//  DatabaseModel.swift
//  RxInstaSample
//

import Firebase
import RxSwift

protocol DatabaseModelProtocol {
    var posts: Observable<[PostDataProtocol]> { get }
    func startPostsListener()
    func stopPostsListener()
    var newPostID: String { get }
    func saveData(postID: String, title: String) -> Observable<Bool>
    func toggleLikes(postData: PostDataProtocol) -> Observable<Bool>
}

enum DatabaseModelError: Error {
    case unknown
}

class DatabaseModel : DatabaseModelProtocol {
    static let shared = DatabaseModel()
    
    static let PostPath = "posts"
    
    private var _posts = PublishSubject<[PostDataProtocol]>()
    
    var listener: ListenerRegistration?
    
    init() {
        if AuthModel.shared.hasLogin {
            startPostsListener()
        }
    }
    
    var posts: Observable<[PostDataProtocol]> {
        return _posts.asObservable()
    }

    func startPostsListener() {
        let postsRef = Firestore.firestore().collection(Self.PostPath).order(by: "date", descending: true)
        self.listener = postsRef.addSnapshotListener() { [unowned self] (querySnapshot, error) in
            if let error = error {
                print(error)
                _posts.onError(error)
                return
            }
            // 取得したdocumentsをPostDataの配列に変換してpostsのストリームに流す
            let posts: [PostDataProtocol] = querySnapshot!.documents.map { document in
                let postData = PostData(document: document)
                print(postData)
                return postData
            }
            _posts.onNext(posts)
        }
    }
    
    func stopPostsListener() {
        self.listener?.remove()
    }
    
    var newPostID: String {
        return Firestore.firestore().collection(Self.PostPath).document().documentID
    }
    
    func saveData(postID: String, title: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            let postRef = Firestore.firestore().collection(Self.PostPath).document(postID)
            let postDic = [
                "name": AuthModel.shared.loginUserName,
                "title": title,
                "date": FieldValue.serverTimestamp(),
            ] as [String : Any]
            postRef.setData(postDic)
            
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func toggleLikes(postData: PostDataProtocol) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            let userID = AuthModel.shared.loginUserID
            if userID != "" {
                // 更新データを作成する
                var updateValue: FieldValue
                if postData.isLiked {
                    updateValue = FieldValue.arrayRemove([userID])
                } else {
                    updateValue = FieldValue.arrayUnion([userID])
                }
                // likedUsersに更新データを書き込む
                let postRef = Firestore.firestore().collection(Self.PostPath).document(postData.id)
                postRef.updateData(["likedUsers": updateValue])
                observer.onNext(true)
                observer.onCompleted()
            } else {
                observer.onError(DatabaseModelError.unknown)
            }
            return Disposables.create()
        }
    }
}

class DatabaseModelMock : DatabaseModelProtocol {
    static let shared =  DatabaseModelMock()
    
    var postsMock: (() -> Observable<[PostDataProtocol]>)?
    var startPostsListenerMock: (() -> ())?
    var stopPostsListenerMock: (() -> ())?
    var newPostIDMock: (() -> String)?
    var saveDataMock: ((_ postID: String, _ title: String) -> Observable<Bool>)?
    var toggleLikesMock: ((_ postData: PostDataProtocol) -> Observable<Bool>)?

    var posts: Observable<[PostDataProtocol]> {
        return postsMock!()
    }
    
    func startPostsListener() {
        return startPostsListenerMock!()
    }
    
    func stopPostsListener() {
        return stopPostsListenerMock!()
    }

    var newPostID: String {
        return newPostIDMock!()
    }
    
    func saveData(postID: String, title: String) -> Observable<Bool> {
        return saveDataMock!(postID, title)
    }
    
    func toggleLikes(postData: PostDataProtocol) -> Observable<Bool> {
        return toggleLikesMock!(postData)
    }
}
