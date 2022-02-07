//
//  SettingViewModelTests.swift
//  RxInstaSample
//

import XCTest
@testable import RxInstaSample
import RxSwift
import RxCocoa
import RxTest

class SettingViewModelTests: XCTestCase {
    
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
    
    func testWithMarble() throws {
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)
        
        // テストするイベントシーケンス
        let timelines = [
            // 発生させるイベント
            "e----d2--------", // displayNameText
            "---x----x------", // changeDisplayNameTap
            "------------x--", // userLogoutTap
            // 期待される結果イベント
            "d1-------------", // displayName
            "---f----t------", // changeDisplayNameValidation
            "----------t----", // changeDisplayNameComplete
            "------------t--", // userLogoutComplete
        ]
        
        let displayNameText = scheduler.parseEventsAndTimes(
            timeline: timelines[0], values: stringValues).first!
        let changeDisplayNameTap = scheduler.parseEventsAndTimes(
            timeline: timelines[1], values: events).first!
        let userLogoutTap = scheduler.parseEventsAndTimes(
            timeline: timelines[2], values: events).first!
        
        let correctDisplayName = scheduler.parseEventsAndTimes(
            timeline: timelines[3], values: stringValues).first!
        let correctChangeDisplayNameValidation = scheduler.parseEventsAndTimes(
            timeline: timelines[4], values: booleans).first!
        let correctChangeDisplayNameComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[5], values: booleans).first!
        let correctUserLogoutComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[6], values: booleans).first!

        // Model作成(モックを使ってイベントを発生させる)
        let model = AuthModelMock.shared
        model.displayNameMock = {
            return scheduler.createObservable(timeline: "d1", values: self.stringValues, errors: self.errors)
        }
        
        model.changeDisplayNameMock = { displayName in
            var timeline: String
            if displayName == "user2" {
                timeline = "--t"
            } else {
                timeline = "--f"
            }
            return scheduler.createObservable(timeline: timeline, values: self.booleans, errors: self.errors)
        }

        model.signOutMock = {
            return scheduler.createObservable(timeline: "t", values: self.booleans, errors: self.errors)
        }

        // ViewModel生成
        let viewModel = SettingViewModel(
            displayNameText: scheduler.createHotObservable(displayNameText).asDriver(onErrorJustReturn: ""),
            changeDisplayNameTap: scheduler.createHotObservable(changeDisplayNameTap).asSignal(onErrorJustReturn: ()),
            userLogoutTap: scheduler.createHotObservable(userLogoutTap).asSignal(onErrorJustReturn: ()),
            model: model
        )
        
        // viewModelの出力のイベントの変化をObserverで受け取れるよう設定
        let displayNameObserver = scheduler.record(source: viewModel.displayName)
        let changeDisplayNameValidationObserver = scheduler.record(source: viewModel.changeDisplayNameValidation)
        let changeDisplayNameCompleteObserver = scheduler.record(source: viewModel.changeDisplayNameComplete)
        let userLogoutCompleteObserver = scheduler.record(source: viewModel.userLogoutComplete)

        // テスト開始
        scheduler.start()
        
        // 生成されたイベントが期待しているものと一致しているかチェックする
        XCTAssertEqual(displayNameObserver.events, correctDisplayName)
        XCTAssertEqual(changeDisplayNameValidationObserver.events, correctChangeDisplayNameValidation)
        XCTAssertEqual(changeDisplayNameCompleteObserver.events, correctChangeDisplayNameComplete)
        XCTAssertEqual(userLogoutCompleteObserver.events, correctUserLogoutComplete)
        
    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
