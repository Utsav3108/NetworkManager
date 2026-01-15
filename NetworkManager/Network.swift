//
//  Network.swift
//  NetworkManager
//
//  Created by Utsav Hitendrabhai Pandya on 14/01/26.
//

import Foundation
import SwiftyJSON
/*
1. Telemetry & Debugging
- Logging
- Request Cancellation
*/

let basePath = "http://localhost:8001/"

enum Method: String {
    case GET
    case PUT
    case POST
    case DELETE
}

struct Request {
    var url: URL
    var httpMethod: Method
    var body : [String : Any]?
    
    func printRequest() {
        print("=======================")
        print("Request: ", url)
        print("Body: ", body ?? [:])
        print("Method: ", httpMethod.rawValue, "\n")
        print("=======================")
    }
}


struct Network {
    
    static let shared = Network()
    
    let urlSession : URLSession
    
    init(urlConfig: URLSessionConfiguration = .default) {
        self.urlSession = URLSession(configuration: urlConfig)
    }
    
    func perform(_ request : Request) async -> Data? {
        
        guard !Task.isCancelled else {
            print("cancelled run")
            return nil
        }
        
        var req = URLRequest(url: request.url)
        
        req.httpMethod = request.httpMethod.rawValue

        if let body = request.body {
            req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        req.allHTTPHeaderFields = ["Content-Type": "application/json"]
                
        let startTime = Date.now
        
        var result : Data?
        var errorMessage : String?
        
        do {
            
            result = try await urlSession.data(for: req).0
            
            
        } catch let error as CancellationError {
            print("❌ Request was explicitly cancelled.")
            errorMessage = error.localizedDescription
        } catch let error as URLError where error.code == .cancelled {
            print("❌ Network request cancelled by URLSession.")
            errorMessage = error.localizedDescription
        } catch let error {
            errorMessage = error.localizedDescription

        }
        
        log(
            request: req,
            response: result ?? Data(),
            error: errorMessage,
            timeTaken: Date.now.timeIntervalSince(startTime)
        )
        
        return nil
    
    }
    
    private func log(request : URLRequest, response : Data, error: String? = nil, timeTaken : TimeInterval) {
        
        print("<======>")
        request.printRequest()
        print("Response: ", JSON(response))
        print("Error: ", error ?? "None")
        print("🕥 Time taken: ", timeTaken, "s")
        print("<======>")
        
    }
    
}

extension URLRequest {
    func printRequest() {
        
        print("👾Request Log")
        print("URL: ", url?.absoluteString ?? "-")
        print("Method: ", httpMethod ?? "-")
        print("Body:", JSON(httpBody ?? Data()))
        print("HTTP Headers: ", allHTTPHeaderFields ?? [:])
        
    }
}
