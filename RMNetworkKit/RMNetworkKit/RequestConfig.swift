//
//  RequestConfig.swift
//  RMNetworkKit
//
//  Created by RMNetworkKit on 2018/1/2.
//  Copyright © 2018年 RMNetworkKit. All rights reserved.
//

import Foundation
import Alamofire

public enum httpMethod: String {
    case GET
    case POST
    //case PUT
    //case DELETE
}

// 数据解析方式
public enum DataParseMethod {
    case UTF8
    case GBK
}

// 参数编码方式
public enum ParamsEncodeingType {
    case URLEncode
    case JsonEncode
    case PropertyListEncoding
}

public class RequestConfig {
    public var methodName: String?                       //方法名称
    public var method: httpMethod = .GET                 //请求方法
    public var parameter: [String: Any]?                 //请求参数
    public var parameterEncoding: ParamsEncodeingType =  .URLEncode
                                                         //参数编码方式
    public var headers: [String: String]?                //设置请求头
    public weak var delegate: requestCallBackDelegate?   //代理
    public var cacheMode: CacheMode = .NO_CACHE          //默认无缓存
    public var dataParseMethod: DataParseMethod = .UTF8  //返回数据的解析方式
    public var isSetCookie: Bool = false                 //是否添加cookie到header中
    
    public var taskArr: [URLSessionTask?] = []           //任务
    public var url: URL?                                 //请求地址
    public var response: DefaultDataResponse?
    public var isCloseContentPrint = false               //是否关闭网络返回数据的打印
    
    /** 默认是GET请求，方法名和参数都为nil */
    public init(delegate: requestCallBackDelegate?, cacheMode: CacheMode = .NO_CACHE) {
        self.delegate  = delegate
        self.cacheMode = cacheMode
    }
    /** 自定义请求参数 */
    public convenience init(_ methodName: String?, _ method: httpMethod, _ parameter: [String: Any]?, _ delegate: requestCallBackDelegate?,  _ cacheMode: CacheMode = .NO_CACHE, _ headers: [String: String]?) {
        self.init(delegate: delegate)
        self.method     = method
        self.parameter  = parameter
        self.methodName = methodName
        self.cacheMode  = cacheMode
        self.headers    = headers
    }
    
    public func cancelTask() {
        for task in taskArr {
            task?.cancel()
        }
    }
    
    deinit {
        self.cancelTask()
    }
}
