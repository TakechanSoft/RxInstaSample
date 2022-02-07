//
//  HomeViewModelTests.swift
//  RxInstaSample
//

import XCTest
@testable import RxInstaSample
import RxSwift
import RxCocoa
import RxTest

class HomeViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let booleans = ["t" : true, "f" : false]
    let events = ["x" : ()]
    let errors = [
        "#1" : NSError(domain: "Some unknown error maybe", code: -1, userInfo: nil),
        "#u" : NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    ]
    let stringValues = [
        "e" : "",
        "d1" : "user1",
        "d2" : "user2",
    ]
    var postsEvents: [String:[PostDataProtocol]] = [:]
    var likeEvents: [String:PostDataProtocol] = [:]
    
    func testWithMarble() throws {
        // PostData作成
        var posts: [PostDataProtocol] = []
        for i in 0 ..< 10 {
            let postData = PostDataMock()
            postData.idMock = { return "id\(i)" }
            postData.nameMock =  { return "name\(i)" }
            postData.titleMock = { return "title\(i)" }
            postData.dateMock = { return Date().addingTimeInterval(TimeInterval(60*i)) }
            postData.likedUsersMock = { return [] }
            postData.isLikedMock = { return false }
            posts.append(postData)
        }
        postsEvents["p"] = posts
        
        likeEvents["p1"] = posts[1]
        
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)
        
        // テストするイベントシーケンス
        let timelines = [
            // 発生させるイベント
            "--p1-----------", // likeButtonTap
            // 期待される結果イベント
            "p--------------", // posts
            "--t------------", // likeComplete
        ]
        
        let likeButtonTap = scheduler.parseEventsAndTimes(
            timeline: timelines[0], values: likeEvents).first!
        
        let correctPosts = scheduler.parseEventsAndTimes(
            timeline: timelines[1], values: postsEvents).first!
        let correctLikeComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[2], values: booleans).first!

        // Model作成(モックを使ってイベントを発生させる)
        let datebaseModel = DatabaseModelMock.shared
        datebaseModel.postsMock = {
            return scheduler.createObservable(timeline: "p", values: self.postsEvents, errors: self.errors)
        }
        
        datebaseModel.toggleLikesMock = { postData in
            return scheduler.createObservable(timeline: "t", values: self.booleans, errors: self.errors)
        }

        // ViewModel生成
        let viewModel = HomeViewModel(
            likeButtonTap: scheduler.createHotObservable(likeButtonTap).asSignal(onErrorJustReturn: PostDataMock()),
            databaseModel: datebaseModel
        )
        
        // viewModelの出力のイベントの変化をObserverで受け取れるよう設定
        let postsObserver = scheduler.record(source: viewModel.posts)
        let likeCompleteObserver = scheduler.record(source: viewModel.likeComplete)

        // テスト開始
        scheduler.start()

        // 生成されたイベントが期待しているものと一致しているかチェックする
        XCTAssertEqual(
            postsObserver.events.map {$0.debugDescription},
            correctPosts.map {$0.debugDescription}
        )
        XCTAssertEqual(likeCompleteObserver.events, correctLikeComplete)
        
    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
