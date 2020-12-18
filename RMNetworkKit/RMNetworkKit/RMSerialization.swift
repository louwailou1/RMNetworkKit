//
//  RMSerialization.swift
//  RMNetworkKit
//
//  Created by RMNetworkKit on 2017/4/14.
//  Copyright © 2017年 RMNetworkKit. All rights reserved.
//

import Foundation

extension Data {
    func json() -> Any?{
        if let json = try? JSONSerialization.jsonObject(with: self, options: .allowFragments) {
            return json
        }else {
            return nil
        }
    }
}
