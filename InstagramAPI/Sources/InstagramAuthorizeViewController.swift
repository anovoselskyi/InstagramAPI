//
//  WebViewController.swift
//  InstagramAPI
//
//  Created by Andrii Novoselskyi on 17.04.2020.
//

import WebKit

class InstagramAuthorizeViewController: UIViewController, WKNavigationDelegate {
    
    var instagramAPI: InstagramAPI?
    
    private var completion: ((Result<UserAccessToken, Error>) -> Void)?
        
    lazy var webView: WKWebView = {
        let _webView = WKWebView()
        _webView.navigationDelegate = self
        view.backgroundColor = .white
        view.addSubview(_webView)
        return _webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupWebView()
    }
}

extension InstagramAuthorizeViewController {
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(sender:)))
    }
    
    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        navigationController?.navigationBar.isTranslucent = false

        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
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

extension InstagramAuthorizeViewController {
    
    @objc private func cancelAction(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
