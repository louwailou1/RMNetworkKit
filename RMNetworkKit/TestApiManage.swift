//
//  TestApiManage.swift
//  RMNetworkKit
//
//  Created by RMNetworkKit on 2018/1/2.
//  Copyright © 2018年 RMNetworkKit. All rights reserved.
//

import Foundation

class ReportRequest: Request {
    var host: String {
        return "http://www.8000dian.com"
    }
    
    
    var requestConfig: RequestConfig
    
    required init(_ config: RequestConfig) {
    
        config.methodName = "report.do"
//        config.dataParseMethod = .GBK
        config.method = .GET
        requestConfig = config
    }
}

class HotMarketRequest: Request {
    
    var host: String {
        return "http://114.215.237.58:1080/api"
    }
    
    var requestConfig: RequestConfig
    required init(_ config: RequestConfig) {
        config.methodName = "market/stocks"
        config.method = .GET
        requestConfig = config
    }
}

