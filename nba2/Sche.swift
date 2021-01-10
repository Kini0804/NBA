//
//  Sche.swift
//  nba2
//
//  Created by 刘少冬 on 2021/1/7.
//

import Foundation
import UIKit
class Sche{
    static func == (lhs: Sche, rhs: Sche) -> Bool {
        if(lhs.nameA == rhs.nameA && lhs.nameB == rhs.nameB && lhs.ymd == rhs.ymd && lhs.hm == rhs.hm){
            return true
        }
        else {
            return false
        }
    }
    
    let nameA: String
    let nameB: String
    let imageA: String
    let imageB: String
    let scoreA: String
    let scoreB: String
    let status: String
    let ymd: String
    let hm: String
    let url: String
    
    init(nameA: String, nameB: String, imageA: String, imageB: String, scoreA: String, scoreB: String, status: String, ymd: String, hm: String, url: String) {
        self.nameA = nameA
        self.nameB = nameB
        self.imageA = imageA
        self.imageB = imageB
        self.scoreA = scoreA
        self.scoreB = scoreB
        self.status = status
        self.ymd = ymd
        self.hm = hm
        self.url = url
    }
}
