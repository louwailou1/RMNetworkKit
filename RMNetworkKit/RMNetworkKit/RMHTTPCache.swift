//
//  RMHTTPCache.swift
//  RMNetworkKit
//
//  Created by RMNetworkKit on 2017/4/13.
//  Copyright © 2017年 RMNetworkKit. All rights reserved.
//

import Foundation
import PINCache

public enum CacheMode {
    case NO_CACHE                   //无缓存模式
    case REQUEST_FAILED_READ_CACHE  //请求网络失败后读取缓存
    case IF_NONE_CACHE_REQUEST      //如果不存在缓存则请求网络，否则使用缓存
    case FIRST_CACHE_THEN_REQUEST   //先使用缓存，不管是否存在，仍然请求网络
}

// memory缓存 disk缓存
public protocol HttpCache {
    /** 保存数据 */
    func saveCache(data: Data, host: String, methodName: String?, parameters: [String:Any]?)
    /** 获取数据 */
    func fetchCacheData(host: String, methodName: String?, parameters: [String:Any]?) -> Data?
    /** 请求参数转为字符串 */
    func inTokeyString(host: String, methodName: String?, parameters: [String:Any]?) -> String
}

extension HttpCache {
    func inTokeyString(host: String, methodName: String?, parameters: [String:Any]?) -> String {
        var key: String = host
        if let methodName = methodName {
            key.append(methodName)
            if let parameters = parameters {
                let str = parameterEncodeing().query(parameters)
                key.append(str)
            }
        }
        return key
    }
}

class RMHTTPCache: HttpCache {
    
    static let shared = RMHTTPCache()
    private init() {}
    
    //保存数据
    func saveCache(data: Data, host: String, methodName: String?, parameters: [String:Any]?) {
        let key = inTokeyString(host: host, methodName: methodName, parameters: parameters)
        saveCache(data: data, key: key)
    }
    
    //获取数据
    func fetchCacheData(host: String, methodName: String?, parameters: [String:Any]?) -> Data? {
        let key = inTokeyString(host: host, methodName: methodName, parameters: parameters)
        return fetchCacheData(key: key)
    }
    
    fileprivate func saveCache(data: Data, key: String) {
        PINCache.shared.setObject(NSData.init(data: data), forKey: key)
    }
    
    fileprivate func fetchCacheData(key: String) -> Data? {
        return PINCache.shared.object(forKey: key) as? Data
    }
}




//MARK:- 请求参数编码
public struct parameterEncodeing {
    
    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

