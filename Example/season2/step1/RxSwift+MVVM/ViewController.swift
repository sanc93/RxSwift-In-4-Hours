//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

//class Observable<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//    
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//    
//    func subscribe(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    // Observable - 나중에 생기는 데이터
    func downloadJson(_ url: String) -> Observable<String?> {
        // 1. 비동기로 생기는 데이터를 옵저버블(Observable)로 감싸서 리턴하는 방법
        return Observable.create() { emitter in
            emitter.onNext("Hello")
            emitter.onNext("World")
            emitter.onCompleted()
            
            return Disposables.create()
        }
    }
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//                
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted() // onCompleted로 아래 클로저가 사라지면서 레퍼런스 카운트 감소, 순환 참조 문제 해결가능
//                }
//            }
//            
//            return Disposables.create()
//        }
//     
//    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(self.activityIndicator, true)
        
        // 2. 옵저버블(Observable)로 오는 데이터를 받아서 리턴하는 방법
        downloadJson(MEMBER_LIST_URL)
        // 나중에 데이터가 오면 .subscribe, next라는 event가 온다
        .subscribe { event in
            switch event {
                // 데이터가 전달될때는 next로 온다
            case let .next(json):
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
                // 데이터가 다 전달되고 완전히 끝났을때는 Completed
            case .completed:
                break
                // 에러가 났을때는 error
            case .error(_):
                break
            }
        }
        //.dispose() // 위에 애니메이션 돌고 JSON 불러오게 시켜놓고 불러오기도 전에 dispose(메모리에서 해제) 시키기 떄문에 로드되지 않는다..
        
        // 아래 두가지만 알면 RxSwift 사용방법을 익혔다고 말할수 있음
        // 1. 비동기로 생기는 데이터를 옵저버블(Observable)로 감싸서 리턴하는 방법
        // 2. 옵저버블(Observable)로 오는 데이터를 받아서 리턴하는 방법
    }
}
