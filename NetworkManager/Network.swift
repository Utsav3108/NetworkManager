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
    
    
    private struct Transaction {
        
        var request : URLRequest
        var response : Data
        var error : String?
        var timeTaken : TimeInterval
        
        func log() {
            
            print("<======>")
            request.printRequest()
            print("Response: ", JSON(response))
            print("Error: ", error ?? "None")
            print("🕥 Time taken: ", timeTaken, "s")
            print("<======>")
            
        }
        
    }
    
    static let shared = Network()
    
    let urlSession : URLSession
    
    let decoder = JSONDecoder()
    
    init(urlConfig: URLSessionConfiguration = .default) {
        self.urlSession = URLSession(configuration: urlConfig)
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func perform<T:Decodable>(_ request : Request) async -> T? {
        
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
        
        var response : Data?
        var errorMessage : String?
        
        var result: T?
        
        do {
            
            response = try await urlSession.data(for: req).0
            
            result = try? decoder.decode(T.self, from: response!)

            
        } catch let error as CancellationError {
            print("❌ Request was explicitly cancelled.")
            errorMessage = error.localizedDescription
        } catch let error as URLError where error.code == .cancelled {
            print("❌ Network request cancelled by URLSession.")
            errorMessage = error.localizedDescription
        } catch let error {
            errorMessage = error.localizedDescription

        }
        
        let transaction = Transaction(
            request: req,
            response: response ?? Data(),
            error: errorMessage,
            timeTaken: Date.now.timeIntervalSince(startTime)
        )
        
        transaction.log()
        
        return result
    
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
