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

// MARK: - Errors
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case unauthorized // 401
    case serverError(Int) // 500 range
    case decodingFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Your session expired. Please log in again."
        case .serverError(let code): return "Server is having trouble (Code: \(code))"
        case .decodingFailed: return "We received data, but couldn't read it."
        default: return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Request / Methods
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

// MARK: - Network Engine
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
        req.allHTTPHeaderFields = ["Authorization": "Bearer mysecrettoken123"]
                
        let startTime = Date.now
        
        var response : Data?
        var errorMessage : String?
        
        var result: T?
        
        do {
            
            let apiResponse = try await urlSession.data(for: req)
            
            try validate(apiResponse.1)
            
            response = apiResponse.0
            
            result = try? decoder.decode(T.self, from: response!)

            
        } catch let error as CancellationError {
            print("❌ Request was explicitly cancelled.")
            errorMessage = error.localizedDescription
        } catch let error as URLError where error.code == .cancelled {
            print("❌ Network request cancelled by URLSession.")
            errorMessage = error.localizedDescription
        } catch let error as NetworkError {
            
            switch error {
            case .unauthorized:
                break
            default:
                break
            }
            
            print("Error: ", error.errorDescription ?? "-")
            errorMessage = error.localizedDescription
        } catch let error as URLError where error.code == .cannotConnectToHost {
            print("ella")
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
    
    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
    
        print("Http StatusCode :", httpResponse.statusCode)
        switch httpResponse.statusCode {
        case 200...299:
            return // All good
        case 401, 404:
            throw NetworkError.unauthorized
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown(URLError(.badServerResponse))
        }
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
