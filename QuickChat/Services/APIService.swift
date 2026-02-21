//
//  APIService.swift
//  QuickChat
//
//  Created by Karlos Flor on 2/19/26.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    private var sessionCookie: HTTPCookie?
    
    func login(username: String, password: String) async throws -> Agent {
        let url = URL(string: "\(Config.apiURL)\(Config.Endpoints.login)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Store session cookie
        if let httpResponse = response as? HTTPURLResponse {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String: String], for: url)
            for cookie in cookies {
                if cookie.name == "sessionId" {
                    sessionCookie = cookie
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        guard loginResponse.success else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: loginResponse.error ?? "Login failed"])
        }
        
        // Save agent to keychain
        if let agentData = try? JSONEncoder().encode(loginResponse.agent) {
            KeychainHelper.shared.save(agentData, for: "agent")
        }
        
        return loginResponse.agent
    }
    
    func checkAuth() async throws -> Agent? {
        let url = URL(string: "\(Config.apiURL)\(Config.Endpoints.checkAuth)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add session cookie
        if let cookie = sessionCookie {
            request.setValue("\(cookie.name)=\(cookie.value)", forHTTPHeaderField: "Cookie")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }
        
        let authResponse = try JSONDecoder().decode(AuthCheckResponse.self, from: data)
        return authResponse.authenticated ? authResponse.agent : nil
    }
    
    func logout() async throws {
        let url = URL(string: "\(Config.apiURL)\(Config.Endpoints.logout)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add session cookie
        if let cookie = sessionCookie {
            request.setValue("\(cookie.name)=\(cookie.value)", forHTTPHeaderField: "Cookie")
        }
        
        let (_, _) = try await URLSession.shared.data(for: request)
        
        sessionCookie = nil
        KeychainHelper.shared.delete(for: "agent")
    }
}
