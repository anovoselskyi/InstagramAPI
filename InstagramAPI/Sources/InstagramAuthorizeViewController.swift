//
//  WebViewController.swift
//  InstagramAPI
//
//  Created by Andrii Novoselskyi on 17.04.2020.
//

import WebKit

class InstagramAuthorizeViewController: UIViewController, WKNavigationDelegate {
    
    var instagramAPI: InstagramAPI?
    
    var completion: ((Result<UserAccessToken, Error>) -> Void)?
    
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
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        setupWebView()
    }
}

extension InstagramAuthorizeViewController {
    
    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if !constraints.isEmpty {
          NSLayoutConstraint.deactivate(constraints)
          constraints.removeAll()
        }
        
        let views = ["webView" : webView]
        let metrics = [
            "topMargin" : view.safeAreaInsets.top,
            "bottomMargin" : view.safeAreaInsets.bottom,
            "leftMargin" : view.safeAreaInsets.left,
            "rightMargin" : view.safeAreaInsets.right
        ]
        
        constraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-topMargin-[webView]-bottomMargin-|",
            metrics: metrics,
            views: views
        )
        
        constraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[webView]-rightMargin-|",
            metrics: metrics,
            views: views
        )
        
        NSLayoutConstraint.activate(constraints)
    }
}
extension InstagramAuthorizeViewController {
    
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
}

extension InstagramAuthorizeViewController {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let completion = completion {
            instagramAPI?.exchangeCodeForToken(from: url, completion: completion)
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }        
}
