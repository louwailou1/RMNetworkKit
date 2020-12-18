
//
//  HttpLogger.swift
//  RMNetworkKit
//
//  Created by RMNetworkKit on 2017/4/14.
//  Copyright © 2017年 RMNetworkKit. All rights reserved.
//

import Foundation

func printLog<T>(_ message: T,
                 logError: Bool = false,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line)
{
    if logError {
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    } else {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        #endif
    }
}

class HTTPLogger {
    
    static func logDebugInfo(response: HTTPURLResponse?, responseData: Data?, request: URLRequest?, error: Error?){
        #if DEBUG
            var logString = "\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"
            
            if let response = response {
                logString.append("Status:\t\(response.statusCode)\t\((HTTPURLResponse.localizedString(forStatusCode: response.statusCode)))\n\n")
            }else {
                logString.append("Status:\t N/A \t N/A \n\n")
            }
            
            if let data = responseData {
                let responseString = String(data: data, encoding: .utf8)
                if let responseString = responseString {
                    logString.append("Content:\n\t\(responseString)\n\n")
                }
            }else {
                logString.append("Content:\n\t N/A \n\n")
            }
            
            if let error = error {
                logString.append("Error :\t\t\t\t\t\t\t\(error)\n")
            }else {
                logString.append("Error :\t\t\t\t\t\t\t N/A \n")
            }
            
            logString.append("\n---------------  Related Request Content  --------------\n")
            
            if let request = request {
                logString.append("\n\nHTTP URL:\n\t\(String(describing: request.url))")
                logString.append("\n\nHTTP Header:\n\t\(String(describing: request.allHTTPHeaderFields))")
                if let body = request.httpBody {
                    if let bodyString = String(data: body, encoding: .utf8) {
                        logString.append("\n\nHTTP Body:\n\t\(bodyString)")
                    }
                }else {
                    logString.append("\n\nHTTP Body:\n\tN/A")
                }
            }
            
        logString.append("\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n")
            print(logString)
        #endif
    }
    
    static func logDebugCachedInfo(_ methodName: String?, _ parameters: [String: Any]?, _ data: Data?){
        var logString = "\n\n==============================================================\n=                      Cached Response                       =\n==============================================================\n\n"
        logString.append("Method Name:\t\(String(describing: methodName))\n")
        logString.append("Params:\t\(String(describing: parameters))\n\n")
        let responseString = String(data: data!, encoding: .utf8)
        if let responseString = responseString {
            logString.append("Content:\n\t\(responseString)\n\n")
        }else {
            logString.append("Content:\n\t N/A \n\n")
        }
    logString.append("\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n")
        print(logString)
    }
    
}
