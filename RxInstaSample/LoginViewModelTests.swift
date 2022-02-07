//
//  LoginViewModelTests.swift
//  RxInstaSample
//

import XCTest
@testable import RxInstaSample
import RxSwift
import RxCocoa
import RxTest

class LoginViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testBasicSample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let scheduler = TestScheduler(initialClock: 0)
        
        let disposeBag = DisposeBag()

        // UI部品に発生するイベントを定義
        let mailAddress = scheduler.createHotObservable([
            Recorded.next(10, ""),
            Recorded.next(30, "test@test.com"),
            Recorded.next(510, ""),
            Recorded.next(530, "test@test.com"),
        ]).asDriver(onErrorJustReturn: "")
        
        let password = scheduler.createHotObservable([
            Recorded.next(10, ""),
            Recorded.next(50, "ngpass"),
            Recorded.next(90, "password"),
            Recorded.next(510, ""),
            Recorded.next(550, "ngpass"),
            Recorded.next(570, "password"),
        ]).asDriver(onErrorJustReturn: "")
        
        let displayName = scheduler.createHotObservable([
            Recorded.next(10, ""),
            Recorded.next(70, "user1"),
        ]).asDriver(onErrorJustReturn: "")
        
        let userCreateTap = scheduler.createHotObservable([
            Recorded.next(20, ()),
            Recorded.next(40, ()),
            Recorded.next(60, ()),
            Recorded.next(80, ()),
            Recorded.next(100, ()),
        ]).asSignal(onErrorJustReturn: ())

        let userLoginTap = scheduler.createHotObservable([
            Recorded.next(520, ()),
            Recorded.next(540, ()),
            Recorded.next(560, ()),
            Recorded.next(580, ()),
        ]).asSignal(onErrorJustReturn: ())

        // Model作成(モックを使ってイベントを発生させる)
        let model = AuthModelMock.shared
        model.createUserMock = {mailAddress, password, displayName in
            var result: Observable<Bool>
            if mailAddress == "test@test.com" &&
                password == "password" &&
                displayName == "user1" {
                result = scheduler.createHotObservable([
                    Recorded.next(110,true)
                ]).asObservable()
            } else {
                result = scheduler.createHotObservable([
                    Recorded.next(90,false)
                ]).asObservable()
            }
            return result
        }

        model.signInMock = {mailAddress, password in
            var result: Observable<Bool>
            if mailAddress == "test@test.com" &&
                password == "password" {
                result = scheduler.createHotObservable([
                    Recorded.next(590,true)
                ]).asObservable()
            } else {
                result =  scheduler.createHotObservable([
                    Recorded.next(570,false)
                ]).asObservable()
            }
            return result
        }
        
        // 期待している正解イベント
        let correctUserCreateValidation = [
            Recorded.next(20, false),
            Recorded.next(40, false),
            Recorded.next(60, false),
            Recorded.next(80, true),
            Recorded.next(100, true),
        ]

        let correctUserCreateComplete = [
            Recorded.next(90, false),
            Recorded.next(110, true),
        ]

        let correctUserLoginValidation = [
            Recorded.next(520, false),
            Recorded.next(540, false),
            Recorded.next(560, true),
            Recorded.next(580, true),
        ]

        let correctUserLoginComplete = [
            Recorded.next(570, false),
            Recorded.next(590, true),
        ]

        // ViewModel生成
        let viewModel = LoginViewModel(
            mailAddress: mailAddress,
            password: password,
            displayName: displayName,
            userCreateTap: userCreateTap,
            userLoginTap: userLoginTap,
            model: model
        )
        
        // 生成されたイベントをObserverで受け取れるよう設定
        let userCreateValidationObserver = scheduler.createObserver(Bool.self)
        viewModel.userCreateValidation
            .emit(to: userCreateValidationObserver)
            .disposed(by: disposeBag)
        
        let userCreateCompleteObserver = scheduler.createObserver(Bool.self)
        viewModel.userCreateComplete
            .emit(to: userCreateCompleteObserver)
            .disposed(by: disposeBag)

        let userLoginValidationObserver = scheduler.createObserver(Bool.self)
        viewModel.userLoginValidation
            .emit(to: userLoginValidationObserver)
            .disposed(by: disposeBag)
        
        let userLoginCompleteObserver = scheduler.createObserver(Bool.self)
        viewModel.userLoginComplete
            .emit(to: userLoginCompleteObserver)
            .disposed(by: disposeBag)

        // テスト開始
        scheduler.start()
        
        // 生成されたイベントが期待しているものと一致しているかチェックする
        XCTAssertEqual(userCreateValidationObserver.events, correctUserCreateValidation)
        XCTAssertEqual(userCreateCompleteObserver.events, correctUserCreateComplete)

        XCTAssertEqual(userLoginValidationObserver.events, correctUserLoginValidation)
        XCTAssertEqual(userLoginCompleteObserver.events, correctUserLoginComplete)

        
        
    }
    
    let booleans = ["t" : true, "f" : false]
    let events = ["x" : ()]
    let errors = [
        "#1" : NSError(domain: "Some unknown error maybe", code: -1, userInfo: nil),
        "#u" : NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    ]
    let stringValues = [
        "e" : "",
        "u1" : "test@test.com",
        "p1" : "ngpass",
        "p2" : "password",
        "d1" : "user1",
    ]
    
    func testWithMarble() throws {
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)
        
        // テストするイベントシーケンス
        let timelines = [
            // 発生させるイベント
            "e-u1---------------e-u1------------", // mailAddress
            "e----p1------p2----e----p1---p2----", // password,
            "e-------d1---------e---------------", // displayName
            "-x--x--x--x----x-------------------", // userCreateTap
            "--------------------x--x--x----x---", // userLoginTap
            // 期待される結果イベント
            "-f--f--f--t----t-------------------", // correctUserCreateValidation
            "------------f----t-----------------", // correctUserCreateComplete
            "--------------------f--f--t----t---", // correctUserLoginValidation
            "----------------------------f----t-", // correctUserLoginComplete
        ]
        
        let mailAddress = scheduler.parseEventsAndTimes(
            timeline: timelines[0], values: stringValues).first!
        let password = scheduler.parseEventsAndTimes(
            timeline: timelines[1], values: stringValues).first!
        let displayName = scheduler.parseEventsAndTimes(
            timeline: timelines[2], values: stringValues).first!
        let userCreateTap = scheduler.parseEventsAndTimes(
            timeline: timelines[3], values: events).first!
        let userLoginTap = scheduler.parseEventsAndTimes(
            timeline: timelines[4], values: events).first!
        let correctUserCreateValidation = scheduler.parseEventsAndTimes(
            timeline: timelines[5], values: booleans).first!
        let correctUserCreateComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[6], values: booleans).first!
        let correctUserLoginValidation = scheduler.parseEventsAndTimes(
            timeline: timelines[7], values: booleans).first!
        let correctUserLoginComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[8], values: booleans).first!

        // Model作成(モックを使ってイベントを発生させる)
        let model = AuthModelMock.shared
        model.createUserMock = {mailAddress, password, displayName in
            var timeline: String
            if mailAddress == "test@test.com" &&
                password == "password" &&
                displayName == "user1" {
                timeline = "--t"
            } else {
                timeline = "--f"
            }
            return scheduler.createObservable(timeline: timeline, values: self.booleans, errors: self.errors)
        }
        
        model.signInMock = {mailAddress, password in
            var timeline: String
            if mailAddress == "test@test.com" &&
                password == "password" {
                timeline = "--t"
            } else {
                timeline = "--f"
            }
            return scheduler.createObservable(timeline: timeline, values: self.booleans, errors: self.errors)
        }

        // ViewModel生成
        let loginViewModel = LoginViewModel(
            mailAddress: scheduler.createHotObservable(mailAddress).asDriver(onErrorJustReturn: ""),
            password: scheduler.createHotObservable(password).asDriver(onErrorJustReturn: ""),
            displayName: scheduler.createHotObservable(displayName).asDriver(onErrorJustReturn: ""),
            userCreateTap: scheduler.createHotObservable(userCreateTap).asSignal(onErrorJustReturn: ()),
            userLoginTap: scheduler.createHotObservable(userLoginTap).asSignal(onErrorJustReturn: ()),
            model: model
        )
        
        // viewModelの出力のイベントの変化をObserverで受け取れるよう設定
        let userCreateValidationObserver = scheduler.record(source: loginViewModel.userCreateValidation)
        let userCreateCompleteObserver = scheduler.record(source: loginViewModel.userCreateComplete)
        let userLoginValidationObserver = scheduler.record(source: loginViewModel.userLoginValidation)
        let userLoginCompleteObserver = scheduler.record(source: loginViewModel.userLoginComplete)
        // テスト開始
        scheduler.start()
        
        // 生成されたイベントが期待しているものと一致しているかチェックする
        XCTAssertEqual(userCreateValidationObserver.events, correctUserCreateValidation)
        XCTAssertEqual(userCreateCompleteObserver.events, correctUserCreateComplete)
        XCTAssertEqual(userLoginValidationObserver.events, correctUserLoginValidation)
        XCTAssertEqual(userLoginCompleteObserver.events, correctUserLoginComplete)
        
    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
