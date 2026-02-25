//
//  Config.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import Foundation

struct Config {
    //    static let apiURL = "https://karloscoverage.com"
    //    static let socketURL = "https://karloscoverage.com"
    
        static let apiURL = "http://192.168.0.96:3000"
        static let socketURL = "http://192.168.0.96:3000"
    
    struct Endpoints {
        static let login = "/api/auth/login"
        static let logout = "/api/auth/logout"
        static let checkAuth = "/api/auth/me"
    }
}
