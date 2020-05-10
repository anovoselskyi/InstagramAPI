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
import RxCocoa

enum InstagramError: String, Error {
    case auth = "Auth error"
    
    var localizedDescription: String {
        switch self {
        case .auth:
            return rawValue
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum Style: String, CaseIterable {
        case imperative = "Imperative"
        case reactive = "Reactive"
    }
    
    enum Auth {
        case `default`
        case custom
    }
        
    var instagramAPI: InstagramAPI = .init(appId: "", appSecret: "", redirectUri: "")
    
    var disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Observable.from(optional: Style.allCases)
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, item, cell in
                cell.textLabel?.text = item.rawValue
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Style.self)
            .subscribe(onNext: { [weak self] style in
                self?.showActionSheet(with: style)
            })
            .disposed(by: disposeBag)
    }
    
    func showActionSheet(with style: Style) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Default authentication", style: .default) { _ in
            self.defaultAuth(with: style)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Custom authentication", style: .default) { _ in
            self.customAuth(with: style)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in
            actionSheet.dismiss(animated: true, completion: nil)
        })
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController {
    
    func defaultAuth(with style: Style) {
        if style == .reactive {
            instagramAPI.authorize(from: self)
                .flatMap { [unowned self] in self.instagramAPI.feed() }
                .subscribe(onNext: { [weak self] feed in
                    DispatchQueue.main.async {
                        self?.loadMedia(for: feed)
                        self?.showSuccess()
                    }
                }, onError: { error in
                    DispatchQueue.main.async {
                        self.showError(error)
                    }
                })
                .disposed(by: disposeBag)
        } else {
            instagramAPI.authorize(from: self) { [weak self] result in
                DispatchQueue.main.async {
                    if result {
                        self?.loadMedia()
                        self?.showSuccess()
                    } else {
                        self?.showError(InstagramError.auth)
                    }
                }
            }
        }
    }
    
    func customAuth(with style: Style) {
        let authViewController = AuthorizeViewController()
        authViewController.instagramAPI = instagramAPI
        if style == .reactive {
            authViewController.authorize()
                .subscribe(onNext: { _ in
                    self.loadMedia()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        self.showSuccess()
                    }
                }, onError: { error in
                    self.showError(error)
                })
            .disposed(by: disposeBag)
        } else {
            authViewController.authorize { result in
                switch result {
                case .success(_):
                    self.loadMedia()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        self.showSuccess()
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showError(error)
                    }
                }
            }
        }
        present(authViewController, animated: true, completion: nil)
    }
}

extension ViewController {
    
    func loadMedia() {
        instagramAPI.feed { [weak self] result in
            guard case .success(let feed) = result else { return }
            self?.loadMedia(for: feed)
        }
    }
    
    func loadMedia(for feed: Feed) {
        for mediaData in feed.data {
            instagramAPI.media(for: mediaData) { result in
                if case .success(let media) = result {
                    print(media.mediaUrl)
                }
            }
        }
    }
}

extension ViewController {
    
    func showSuccess() {
        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
