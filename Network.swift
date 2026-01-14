//
//  Network.swift
//  NetworkManager
//
//  Created by Utsav Hitendrabhai Pandya on 14/01/26.
//

import Foundation
import SwiftyJSON

/*
 === Core Responsibilities ===
 1. Request Optimization
 - Debouncing/Throttling
 - Request Coalescing
 - Caching
 2. Reliability & Resilience
 - Retry Logic
 - Exponential Backoff
 - Connectivity Monitoring
 3. Security & Authentication
 - Header Injection
 - Token Refresh
 - SSL Pinning
 4. Data Processing
 - Serialization/Deserialization
 - Error Mapping
 - Response Validation
 5. Telemetry & Debugging
 - Logging
 - Metrics Tracking
 - Request Cancellation
 */


let basePath = "http://localhost:8000/"

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
    
    let urlSession : URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func perform(_ request : Request) async {
        
        var req = URLRequest(url: request.url)
        
        req.httpMethod = request.httpMethod.rawValue

        if let body = request.body {
            req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        req.allHTTPHeaderFields = ["Content-Type": "application/json"]
                
        do {
            
            let startTime = Date.now
            
            let result = try await urlSession.data(for: req)
            
            let endTime = Date.now
            
            log(request: req, response: result.0, timeTaken: endTime.timeIntervalSince(startTime))
            
        } catch {
            print("Error: ", error.localizedDescription)
        }
    
    }
    
    private func log(request : URLRequest, response : Data, timeTaken : TimeInterval) {
        
        print("<======>")
        request.printRequest()
        print("Response: ", JSON(response))
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
        
    }
}
