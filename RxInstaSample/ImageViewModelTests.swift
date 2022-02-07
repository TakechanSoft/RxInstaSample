//
//  ImageViewModelTests.swift
//  RxInstaSample
//
//  Created by take on 2022/01/15.
//

import XCTest
@testable import RxInstaSample
import RxSwift
import RxCocoa
import RxTest

class ImageViewModelTests: XCTestCase {
    
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
//    let stringValues = [
//        "e" : "",
//        "d1" : "user1",
//        "d2" : "user2",
//    ]
    let pickedImages = [
        "p1" : UIImage(systemName: "circle")!,
        "p2" : UIImage(systemName: "camera")!
    ]
    let editedImages = [
        "e1" : (UIViewController(), UIImage(systemName: "circle")!),
        "e2" : (UIViewController(), UIImage(systemName: "camera")!)
    ]

    func testWithMarble() throws {
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)
        
        // テストするイベントシーケンス
        let timelines = [
            // 発生させるイベント
            "x-------------", // libraryButtonTap
            "------x-------", // cameraButtonTap
            "------------x-", // cancelButtonTap
            // 期待される結果イベント
            "--x-----x-----", // postImageComplete
            "------------x-", // closeScreen
        ]
        
        let libraryButtonTap = scheduler.parseEventsAndTimes(
            timeline: timelines[0], values: events).first!
        let cameraButtonTap = scheduler.parseEventsAndTimes(
            timeline: timelines[1], values: events).first!
        let cancelButtonTap = scheduler.parseEventsAndTimes(
            timeline: timelines[2], values: events).first!
        
        let correctPostImageComplete = scheduler.parseEventsAndTimes(
            timeline: timelines[3], values: events).first!
        let correctCloseScreen = scheduler.parseEventsAndTimes(
            timeline: timelines[4], values: events).first!

        // Model作成(モックを使ってイベントを発生させる)
        let imagePickerModel = ImagePickerModelMock(viewController: UIViewController())
        imagePickerModel.pickImageMock = { type in
            if type == .photoLibrary {
                return scheduler.createObservable(timeline: "-p1", values: self.pickedImages, errors: self.errors)
            } else {
                return scheduler.createObservable(timeline: "-p2", values: self.pickedImages, errors: self.errors)
            }
        }
        
        let imageEditorModel = ImageEditorModelMock(viewController: UIViewController())
        imageEditorModel.editImageMock = { image in
            return scheduler.createObservable(timeline: "-x", values: self.events, errors: self.errors)
        }

        // ViewModel生成
        let viewModel = ImageViewModel(
            libraryButtonTap: scheduler.createHotObservable(libraryButtonTap).asSignal(onErrorJustReturn: ()),
            cameraButtonTap: scheduler.createHotObservable(cameraButtonTap).asSignal(onErrorJustReturn: ()),
            cancelButtonTap: scheduler.createHotObservable(cancelButtonTap).asSignal(onErrorJustReturn: ()),
            imagePickerModel: imagePickerModel,
            imageEditorModel: imageEditorModel
        )
        
        // viewModelの出力のイベントの変化をObserverで受け取れるよう設定
        let postImageComplete = scheduler.record(source: viewModel.postImageComplete)
        let closeScreen = scheduler.record(source: viewModel.closeScreen)

        // テスト開始
        scheduler.start()
        
        // 生成されたイベントが期待しているものと一致しているかチェックする
        XCTAssertEqual(
            postImageComplete.events.map {$0.debugDescription},
            correctPostImageComplete.map {$0.debugDescription}
        )

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
