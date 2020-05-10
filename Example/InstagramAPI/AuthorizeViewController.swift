//
//  AuthorizeViewController.swift
//  InstagramAPI_Example
//
//  Created by Andrii Novoselskyi on 10.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import WebKit
import InstagramAPI
import RxSwift

class AuthorizeViewController: UIViewController, WKNavigationDelegate {
    
    var instagramAPI: InstagramAPI?
    
    private var completion: ((Result<UserAccessToken, Error>) -> Void)?
    
    private let didComplete = PublishSubject<UserAccessToken>()
    
    private var constraints: [NSLayoutConstraint] = []
    
    lazy var webView: WKWebView = {
        let _webView = WKWebView()
        _webView.navigationDelegate = self
        view.backgroundColor = .white
        view.addSubview(_webView)
        return _webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
    }
}

extension AuthorizeViewController {
    
    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if !constraints.isEmpty {
          NSLayoutConstraint.deactivate(constraints)
          constraints.removeAll()
        }
                
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
}
extension AuthorizeViewController {
    
    func authorize(completion: @escaping (Result<UserAccessToken, Error>) -> Void) {
        self.completion = completion
        instagramAPI?.authorize { [weak self] result in
            if case .success(let url) = result {
                DispatchQueue.main.async {
                    self?.webView.load(URLRequest(url: url))
                }
            }
        }
    }
    
    func authorize() -> Observable<UserAccessToken> {
        instagramAPI?.authorize { [weak self] result in
            if case .success(let url) = result {
                DispatchQueue.main.async {
                    self?.webView.load(URLRequest(url: url))
                }
            }
        }
        
        return didComplete.asObservable()
    }
}

extension AuthorizeViewController {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            instagramAPI?.exchangeCodeForToken(from: url) { [weak self] result in
                self?.completion?(result)
                
                switch result {
                case .success(let token):
                    self?.didComplete.onNext(token)
                    self?.didComplete.onCompleted()
                case .failure(let error):
                    self?.didComplete.onError(error)
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}
