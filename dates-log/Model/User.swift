//
//  User.swift
//  dates-log
//
//  Created by Tong Ying on 9/9/24.
//

import Foundation

struct User: Codable {
    let uId: String // firebase userid
    let tokenId: String //google idtoken
    let name: String
    let email: String
}
