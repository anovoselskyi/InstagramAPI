//
//  URLComponents.swift
//  InstaPreview
//
//  Created by Andrii Novoselskyi on 20.04.2020.
//  Copyright © 2020 Andrii Novoselskyi. All rights reserved.
//

import Foundation

extension URLComponents {
    
    init(scheme: String? = nil, host: String? = nil, path: String? = nil, queryItems: [URLQueryItem]? = nil) {
        self.init()
        
        self.scheme = scheme
        self.host = host
        if let path = path {
            self.path = path
        }
        
        self.queryItems = queryItems
    }
}
