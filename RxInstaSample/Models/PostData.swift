//
//  PostData.swift
//  RxInstaSample
//

import Firebase

protocol PostDataProtocol {
    var id: String { get }
    var name: String { get }
    var title: String { get }
    var date: Date? { get }
    var likedUsers: [String] { get }
    var isLiked: Bool { get }
}

class PostData: PostDataProtocol, CustomStringConvertible {
    var id: String
    var name: String
    var title: String
    var date: Date?
    var likedUsers: [String] = []
    private var _isLiked: Bool?
    var isLiked: Bool {
        if let _isLiked = _isLiked {
            return _isLiked
        } else {
            let myID = AuthModel.shared.loginUserID
            if likedUsers.firstIndex(of: myID) != nil {
                _isLiked = true
                return true
            } else {
                return false
            }
        }
    }
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()

        self.name = postDic["name"] as! String

        self.title = postDic["title"] as! String

        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()

        if let likedUsers = postDic["likedUsers"] as? [String] {
            self.likedUsers = likedUsers
        }
    }
    
    var description: String {
        var dateString = "nil"
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateString = dateFormatter.string(from: date)
        }
        return "PostData id=\(id) date=\(dateString) name=\(name) title=\(title) likedUsers=\(likedUsers.count) isLiked=\(isLiked)"
    }

}

class PostDataMock: PostDataProtocol, CustomStringConvertible  {
    var idMock: (()->String)?
    var nameMock: (()->String)?
    var titleMock: (()->String)?
    var dateMock: (()->Date?)?
    var likedUsersMock: (()->[String])?
    var isLikedMock: (()->Bool)?

    var id: String {
        return idMock!()
    }
    var name: String {
        return nameMock!()
    }
    var title: String {
        return titleMock!()
    }
    var date: Date? {
        return dateMock!()
    }
    var likedUsers: [String] {
        return likedUsersMock!()
    }
    var isLiked: Bool {
        return isLikedMock!()
    }
    
    var description: String {
        var dateString = "nil"
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateString = dateFormatter.string(from: date)
        }
        return "PostData id=\(id) date=\(dateString) name=\(name) title=\(title) likedUsers=\(likedUsers.count) isLiked=\(isLiked)"
    }
}
