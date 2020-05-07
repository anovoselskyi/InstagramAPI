//
//  InstagramAPI+Rx.swift
//  InstagramAPI
//
//  Created by Andrii Novoselskyi on 23.04.2020.
//

import Foundation
import RxSwift

extension InstagramAPI {
    
    func authorize(from viewController: UIViewController) -> Observable<Void> {
        return .create { [weak self] observer -> Disposable in
            self?.authorize(from: viewController) { result in
                if result {
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    observer.onError(InstagramError.generic)
                }
            }
            return Disposables.create()
        }
    }
    
    func instagramUser() -> Observable<User> {
        return .create { [weak self] observer -> Disposable in
            self?.user(completion: { result in
                switch result {
                case .success(let user):
                    observer.onNext(user)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    func feed() -> Observable<Feed> {
        return .create { [weak self] observer -> Disposable in
            self?.feed(completion: { result in
                switch result {
                case .success(let feed):
                    observer.onNext(feed)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    func media(for mediaData: MediaData) -> Observable<Media> {
        return .create { [weak self] observer -> Disposable in
            self?.media(for: mediaData, completion: { result in
            switch result {
                case .success(let media):
                    observer.onNext(media)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }

            })
            return Disposables.create()
        }
    }
}
