//
//  ViewController.swift
//  InstagramAPI
//
//  Created by anovoselskyi on 05/06/2020.
//  Copyright (c) 2020 anovoselskyi. All rights reserved.
//

import UIKit
import InstagramAPI
import RxSwift

class ViewController: UIViewController {
    
    var instagramAPI: InstagramAPI = .init(appId: "", appSecret: "", redirectUri: "")
    
    var disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        instagramAPI.authorize(from: self)
            .subscribe()
            .disposed(by: disposeBag)
    }
}

