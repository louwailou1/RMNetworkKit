
//
//  CoreHttpApi.swift
//  RMNetworkKit
//
//  Created by RMNetworkKit on 2017/4/11.
//  Copyright © 2017年 RMNetworkKit. All rights reserved.
//

import Foundation
import Alamofire

//代理发请求(这里相当于一个接口，任何遵守这个协议的类，都可以发送请求，后续我会添加上传和下载)
protocol Client {
    func send<T: Request>(_ r: T)
}

//dataTask请求
struct URLSessionClient: Client {
    
    func send<T: Request>(_ r: T) {
        var realHost = r.host
        let trueMethodName: String = "/\(r.requestConfig.methodName ?? "")"
        realHost += trueMethodName
        realHost = realHost.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: realHost)!
        var request = URLRequest(url: url)
        request.httpMethod = r.requestConfig.method.rawValue
        // 这里设置请求头貌似无效，好像用下面realReuest有效，未去研究Alamofire源码
        if let headers = r.requestConfig.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let parameters: Parameters? = r.requestConfig.parameter
        var Encoding: ParameterEncoding = URLEncoding.default
        if r.requestConfig.parameterEncoding == .JsonEncode {
            Encoding = JSONEncoding.default
        }else if r.requestConfig.parameterEncoding == .PropertyListEncoding {
            Encoding = PropertyListEncoding.default
        }
        if var realReuest = try? Encoding.encode(request, with: parameters) {
            
            printLog("\n==================================\n\nRequest Start: \n\n \(realReuest.url?.absoluteString ?? "N/A")\n\n==================================")

            realReuest.timeoutInterval = 20 //超时时间20s
            
            if r.requestConfig.cacheMode == .IF_NONE_CACHE_REQUEST || r.requestConfig.cacheMode == .FIRST_CACHE_THEN_REQUEST {
                //使用缓存
                let result = RMHTTPCache.shared.fetchCacheData(host: realHost, methodName: r.requestConfig.methodName, parameters: r.requestConfig.parameter)
                printLog("读取缓存中...")
                if let callBackData = result {
                    
                    if r.requestConfig.isCloseContentPrint {
                        HTTPLogger.logDebugCachedInfo(r.requestConfig.methodName, r.requestConfig.parameter, "isCloseContentPrint==false,关闭返回数据打印".data(using: .utf8)!)
                    }else {
                        HTTPLogger.logDebugCachedInfo(r.requestConfig.methodName, r.requestConfig.parameter, callBackData)
                    }
                    
                    DispatchQueue.main.async {
                        r.willSuccess(data: callBackData, request: r)
                        r.requestConfig.delegate?.callBackSuccess(data: callBackData, request: r) }
                    
                    if r.requestConfig.cacheMode == .IF_NONE_CACHE_REQUEST {
                        return
                    }
                }else {
                    printLog("缓存读取失败")
                }
            }
            
            //设置cookie
            if r.requestConfig.isSetCookie {
                realReuest.setValue(LoginStatus.cookieStr, forHTTPHeaderField: "Cookie")
            }
            
            // 设置请求头
            if let headers = r.requestConfig.headers {
                for (key, value) in headers {
                    realReuest.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            let dataRequest = Alamofire.request(realReuest).validate().response { [weak r] (response) in
                r?.requestConfig.response = response
                if let error = response.error {
                    
                    if r?.requestConfig.isCloseContentPrint != nil && r!.requestConfig.isCloseContentPrint {
                        HTTPLogger.logDebugInfo(response: response.response, responseData: "isCloseContentPrint==false,关闭返回数据打印".data(using: .utf8)!, request: response.request, error: response.error)
                    }else {
                        HTTPLogger.logDebugInfo(response: response.response, responseData: response.data, request: response.request, error: response.error)
                    }
                    
                    if r?.requestConfig.cacheMode == .REQUEST_FAILED_READ_CACHE {//请求失败读取缓存
                        let result = RMHTTPCache.shared.fetchCacheData(host: realHost, methodName: r?.requestConfig.methodName, parameters: r?.requestConfig.parameter)
                        printLog("请求失败,读取缓存中...")
                        if let callBackData = result {
                            DispatchQueue.main.async {
                                r?.willSuccess(data: callBackData, request: r!)
                                r?.requestConfig.delegate?.callBackSuccess(data: callBackData, request: r!) }
                            return
                        }else {
                            printLog("缓存读取失败")
                        }
                    }
                    DispatchQueue.main.async {
                        r?.willFailed(error: error, request: r!)
                        r?.requestConfig.delegate?.callBackError(error: error, request: r!) }
                }else {
                    
                    if let data = response.data {
                        var newData = data
                        
                        if r?.requestConfig.dataParseMethod == .GBK {
                            let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                            let str = NSString(data: data, encoding: enc)
                            
                            if str != nil {
                                let newstr = str! as String
                                newData = newstr.data(using: .utf8)!
                            }
                        }
                        
                        if r?.requestConfig.isCloseContentPrint != nil && r!.requestConfig.isCloseContentPrint {
                            
                            HTTPLogger.logDebugInfo(response: response.response, responseData: "isCloseContentPrint==false,关闭返回数据打印".data(using: .utf8)!, request: response.request, error: response.error)
                        }else {
                            HTTPLogger.logDebugInfo(response: response.response, responseData: newData, request: response.request, error: response.error)
                        }
                        
                        
                        
                        
                        
                        //假如页面返回，r和delegate则变为nil，所以不会执行回调
                        DispatchQueue.main.async {
                            r?.willSuccess(data: newData, request: r!)
                            r?.requestConfig.delegate?.callBackSuccess(data: newData, request: r!) }
                        
                        //缓存网络数据
                        if r?.requestConfig.cacheMode != .NO_CACHE {
                            RMHTTPCache.shared.saveCache(data: newData, host: realHost, methodName: r?.requestConfig.methodName, parameters: r?.requestConfig.parameter)
                        }
                        
                    }
                }
                
            }
            r.requestConfig.taskArr.append(dataRequest.task)
            r.requestConfig.url = realReuest.url
        }
        
        }
}

