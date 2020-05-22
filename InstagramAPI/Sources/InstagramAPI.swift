//
//  InstagramAPI.swift
//  InstagramAPI
//
//  Created by Andrii Novoselskyi on 17.04.2020.
//

import UIKit

enum InstagramError: Error {
    case generic
}

public class InstagramAPI {
                
    // MARK: - Constants
    
    private struct Constants {
        static let boundary = "boundary=\(NSUUID().uuidString)"
    }
    
    // MARK: - Enums
    
    private enum SchemeURL: String {
        case https
        case http
    }

    private enum HostURL: String {
        case displayApi = "api.instagram.com"
        case graphApi = "graph.instagram.com"
    }
        
    private enum Path: String {
        case authorize = "/oauth/authorize"
        case accessToken = "/oauth/access_token"
        case media = "/media"
        case children = "/children"
    }
    
    // MARK: - Public Instance Members
    
    var appId: String

    var appSecret: String
    
    var redirectUri: String
        
    private(set) var currentUser: User?
    
    public var isAuthorized: Bool {
        return userAccessToken != nil
    }
    
    // MARK: - Private Instance Members
    
    private var userAccessToken: UserAccessToken?
    
    // MARK: - Initializers
    
    public init(appId: String, appSecret: String, redirectUri: String) {
        self.appId = appId
        self.appSecret = appSecret
        self.redirectUri = redirectUri
    }
}

// MARK: - Public Methods

extension InstagramAPI {
    
    public func authorize(from viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        let authorizeViewController = InstagramAuthorizeViewController()
        authorizeViewController.instagramAPI = self
        authorizeViewController.authorize { result in
            DispatchQueue.main.async {
                viewController.dismiss(animated: true) {
                    switch result {
                    case .success(let userAccessToken):
                        self.userAccessToken = userAccessToken
                        completion(nil)
                    case .failure(let error):
                        assertionFailure(error.localizedDescription)
                        completion(error)
                    }
                }
            }
        }
        viewController.present(UINavigationController(rootViewController: authorizeViewController), animated:true)
    }
    
    public func authorize(completion: @escaping (Result<URL, Error>) -> Void ) {
        var urlComponents = URLComponents(scheme: SchemeURL.https.rawValue, host: HostURL.displayApi.rawValue, path: Path.authorize.rawValue)
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: appId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: "user_profile,user_media"),
            URLQueryItem(name: "response_type", value: "code")
        ]
        
        guard let requestUrl = urlComponents.url else {
            assertionFailure()
            return
        }
        
        let request = URLRequest(url: requestUrl)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = response?.url {
                completion(.success(url))
            } else {
                assertionFailure("Unreachable code")
                completion(.failure(InstagramError.generic))
            }
        })
        task.resume()
    }
    
    public func exchangeCodeForToken(from url: URL, completion: @escaping (Result<UserAccessToken, Error>) -> Void) {
        var authToken = ""
        if url.absoluteString.starts(with: "\(redirectUri)?code=") {
            if let range = url.absoluteString.range(of: "\(redirectUri)?code=") {
                authToken = String(url.absoluteString[range.upperBound...].dropLast(2))
            } else {
                return
            }
        }
        
        let headers = [
            "content-type": "multipart/form-data; boundary=\(Constants.boundary)"
        ]
        let parameters = [
            [
                "name": "client_id",
                "value": appId
            ],
            [
                "name": "client_secret",
                "value": appSecret
            ],
            [
                "name": "grant_type",
                "value": "authorization_code"
            ],
            [
                "name": "redirect_uri",
                "value": redirectUri
            ],
            [
                "name": "code",
                "value": authToken
            ]
        ]
                        
        let urlComponents = URLComponents(scheme: SchemeURL.https.rawValue, host: HostURL.displayApi.rawValue, path: Path.accessToken.rawValue)
                
        guard let requestUrl = urlComponents.url else {
            assertionFailure()
            return
        }
        
        var request = URLRequest(url: requestUrl)
        
        let postData = makeFormBody(parameters: parameters, boundary: Constants.boundary)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let userAccessToken = try JSONDecoder().decode(UserAccessToken.self, from: data)
                        self?.userAccessToken = userAccessToken
                        completion(.success(userAccessToken))
                    } catch {
                        // Completion failure not handled due to url redirection
                        print(error)
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    public func user(completion: @escaping (Result<User, Error>) -> Void) {
        guard let userAccessToken = userAccessToken else {
            completion(.failure(InstagramError.generic))
            return
        }
        
        var urlComponents = URLComponents(scheme: SchemeURL.https.rawValue, host: HostURL.graphApi.rawValue, path: "/\(userAccessToken.userId)")
        urlComponents.queryItems = [
            URLQueryItem(name: "fields", value: "id,username"),
            URLQueryItem(name: "access_token", value: userAccessToken.token)
        ]
        
        guard let requestUrl = urlComponents.url else {
            assertionFailure()
            return
        }

        let request = URLRequest(url: requestUrl)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let instagramUser = try JSONDecoder().decode(User.self, from: data)
                        self.currentUser = instagramUser
                        completion(.success(instagramUser))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    assertionFailure("Unreachable code")
                    completion(.failure(InstagramError.generic))
                }
            }
        })
        dataTask.resume()
    }
    
    public func feed(after feed: Feed? = nil, completion: @escaping (Result<Feed, Error>) -> Void) {
        guard let userAccessToken = userAccessToken else {
            completion(.failure(InstagramError.generic))
            return
        }
        
        var urlComponents = URLComponents(scheme: SchemeURL.https.rawValue, host: HostURL.graphApi.rawValue, path: "/\(userAccessToken.userId)\(Path.media.rawValue)")
        urlComponents.queryItems = [
            URLQueryItem(name: "fields", value: "id,caption"),
            URLQueryItem(name: "access_token", value: userAccessToken.token),
        ]
        
        if let afterFeed = feed {
            urlComponents.queryItems?.append(URLQueryItem(name: "after", value: afterFeed.paging.cursors.after))
        }
                
        guard let requestUrl = urlComponents.url else {
            assertionFailure()
            return
        }
        
        let request = URLRequest(url: requestUrl)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let feed = try JSONDecoder().decode(Feed.self, from: data)
                        completion(.success(feed))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    assertionFailure("Unreachable code")
                    completion(.failure(InstagramError.generic))
                }
            }
        })
        task.resume()
    }
        
    public func media(for mediaData: MediaData, completion: @escaping (Result<Media, Error>) -> Void) {
        guard let userAccessToken = userAccessToken else {
            completion(.failure(InstagramError.generic))
            return
        }
        
        var urlComponents = URLComponents(scheme: SchemeURL.https.rawValue, host: HostURL.graphApi.rawValue, path: "/\(mediaData.id)")
        urlComponents.queryItems = [
            URLQueryItem(name: "fields", value: "id,media_type,media_url,thumbnail_url,username,timestamp"),
            URLQueryItem(name: "access_token", value: userAccessToken.token)
        ]
        
        guard let requestUrl = urlComponents.url else {
            assertionFailure()
            completion(.failure(InstagramError.generic))
            return
        }

        let request = URLRequest(url: requestUrl)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let media = try JSONDecoder().decode(Media.self, from: data)
                        completion(.success(media))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    assertionFailure("Unreachable code")
                    completion(.failure(InstagramError.generic))
                }
            }
        })
        task.resume()
    }
    
    public func children(for mediaData: MediaData, completion: @escaping (Result<Children, Error>) -> Void) {
        guard let userAccessToken = userAccessToken else {
            completion(.failure(InstagramError.generic))
            return
        }
        
        var urlComponents = URLComponents(scheme: SchemeURL.https.rawValue, host: HostURL.graphApi.rawValue, path: "/\(mediaData.id)\(Path.children.rawValue)")
        urlComponents.queryItems = [
            URLQueryItem(name: "fields", value: "id,media_type,media_url,thumbnail_url,username,timestamp"),
            URLQueryItem(name: "access_token", value: userAccessToken.token)
        ]
        
        guard let requestUrl = urlComponents.url else {
            assertionFailure()
            completion(.failure(InstagramError.generic))
            return
        }
        
        let request = URLRequest(url: requestUrl)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let children = try JSONDecoder().decode(Children.self, from: data)
                        completion(.success(children))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    assertionFailure("Unreachable code")
                    completion(.failure(InstagramError.generic))
                }
            }
        })
        task.resume()
    }

}

// MARK: - Private Methods

extension InstagramAPI {
            
    private func makeFormBody(parameters: [[String : String]], boundary: String) -> Data {
        var body = ""
        let error: NSError? = nil
        for param in parameters {
            let paramName = param["name"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
                var fileContent: String = ""
                do { fileContent = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)}
                catch {
                    print(error)
                }
                if (error != nil) {
                    print(error!)
                }
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                body += fileContent
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        return body.data(using: .utf8)!
    }
}
