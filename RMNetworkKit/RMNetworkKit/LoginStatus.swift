//
//  LoginStatus.swift
//  eightThousandPoints
//
//  Created by RMNetworkKit on 2017/9/3.
//  Copyright © 2017年 RMNetworkKit. All rights reserved.
//

import UIKit

class LoginStatus {
    
    //MARK:- propertities
    static let cookieKeyName = "JSESSIONID"
    static let cookieSaveTime = "cookieSaveTime"
    
    public static var cookieStr: String? {
        get{
            if let str = UserDefaults.standard.value(forKey: cookieKeyName) as? String {
                return str
            }
            return nil
        }
    }
    
    //MARK:- 判断是否需要登录 10分钟算超时
    public static var isNeedLogin: Bool {
        get{
            if let beforeTime = UserDefaults.standard.value(forKey: cookieSaveTime) as? Date {
                let currentTime = Date()
                let second = currentTime.timeIntervalSince(beforeTime)
                if second > 500 {
                    return true
                }else {
                    return false
                }
            }
            return true
        }
    }
    
    //MAKR:- 保存登录cookie
    public class func keepLoginSession(cookie: String) {
        UserDefaults.standard.set(cookie, forKey: cookieKeyName)
        UserDefaults.standard.set(Date(), forKey: cookieSaveTime)
    }
    
    //MARK:- 取消登录状态
    public class func removeLoginSession() {
        UserDefaults.standard.removeObject(forKey: cookieKeyName)
        UserDefaults.standard.removeObject(forKey: cookieSaveTime)
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
