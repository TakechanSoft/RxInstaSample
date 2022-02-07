//
//  PostViewModelTests.swift
//  RxInstaSample
//

import XCTest
@testable import RxInstaSample
import RxSwift
import RxCocoa
import RxTest

class PostViewModelTests: XCTestCase {
    
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
    let strings = [
        "e" : "",
        "s1" : "caption message",
        "u1" : "user1",
    ]
    let images = [
        "i1" : UIImage(systemName: "circle")!,
    ]
    
    var putImageCounter = 0

    func testWithMarble() throws {
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)
        
        // テストするイベントシーケンス
        let timelines = [
            // 発生させるイベント
            "i1----------------", // image
            "e--s1-------------", // textFieldText
            "------x---x-------", // postButtonTap
            "----------------x-", // cancelButtonTap
            // 期待される結果イベント
            "i1----------------", // image
            "------x---x-------", // postDataStart
            "--------f---t-----", // putImageComplete
            "--------------t---", // postDataComplete
            "----------------x-", // closeScreen
            ]
        
        let sourceImage = scheduler.parseEventsAndTimes(
            timeline: timelines[0], values: images).first!
        let textFieldText = scheduler.parseEventsAndTimes(
            timeline: timelines[1], values: strings).first!
        let postButtonTap = scheduler.parseEventsAndTimes(
            timeline: timelines[2], values: events).first!
        let cancelButtonTap = scheduler.parseEventsAndTimes(
            timeline: timelines[3], values: events).first!

        let correctImage = scheduler.parseEventsAndTimes(
            timeline: timelines[4], values: images).first!
        let correctPostDataStart = scheduler.parseEventsAndTimes(
            timeline: timelines[5], values: events).first!
        let correctPutImageComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[6], values: booleans).first!
        let correctPostDataComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[7], values: booleans).first!
        let correctCloseScreen = scheduler.parseEventsAndTimes(
            timeline: timelines[8], values: events).first!

        // Model作成(モックを使ってイベントを発生させる)
        let authModel = AuthModelMock.shared
        authModel.displayNameMock = {
            return scheduler.createObservable(timeline: "u1", values: self.strings, errors: self.errors)
        }

        let databaseModel = DatabaseModelMock.shared
        databaseModel.newPostIDMock = {
            return "documentID1"
        }
        databaseModel.saveDataMock = { postID, title in
            return scheduler.createObservable(timeline: "--t", values: self.booleans, errors: self.errors)
        }
        
        let storageModel = StorageModelMock.shared
        storageModel.putImageMock = { image, path in
            self.putImageCounter += 1
            if self.putImageCounter == 1 {
                // putImage失敗
                return scheduler.createObservable(timeline: "--f", values: self.booleans, errors: self.errors)
            } else {
                // putImage成功
                return scheduler.createObservable(timeline: "--t", values: self.booleans, errors: self.errors)
            }
        }

        // ViewModel生成
        let viewModel = PostViewModel(
            image: scheduler.createHotObservable(sourceImage).asDriver(onErrorJustReturn: UIImage()),
            textFieldText: scheduler.createHotObservable(textFieldText).asDriver(onErrorJustReturn: ""),
            postButtonTap: scheduler.createHotObservable(postButtonTap).asSignal(onErrorJustReturn: ()),
            cancelButtonTap: scheduler.createHotObservable(cancelButtonTap).asSignal(onErrorJustReturn: ()),
            authModel: authModel,
            databaseModel: databaseModel,
            storageModel: storageModel
            )
        
        // viewModelの出力のイベントの変化をObserverで受け取れるよう設定
        let image = scheduler.record(source: viewModel.image)
        let postDataStart = scheduler.record(source: viewModel.postDataStart)
        let putImageComplete = scheduler.record(source: viewModel.putImageComplete)
        let postDataComplete = scheduler.record(source: viewModel.postDataComplete)
        let closeScreen = scheduler.record(source: viewModel.closeScreen)

        // テスト開始
        scheduler.start()
        
        // 生成されたイベントが期待しているものと一致しているかチェックする
        XCTAssertEqual(image.events, correctImage)
        XCTAssertEqual(
            postDataStart.events.map {$0.debugDescription},
            correctPostDataStart.map {$0.debugDescription}
        )
        XCTAssertEqual(putImageComplete.events, correctPutImageComplete)
        XCTAssertEqual(postDataComplete.events, correctPostDataComplete)
        XCTAssertEqual(
            closeScreen.events.map {$0.debugDescription},
            correctCloseScreen.map {$0.debugDescription}
        )

    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
