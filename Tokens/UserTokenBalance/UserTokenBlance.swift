//
//  UserTokenBlance.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-17.
//
// ** data model **

import Foundation

struct UserTokenBlance {
    var userId: String = ""
    var pending: Double = 0.0
    var unclaimed: Double = 0.0
    var reserved: Double = 0.0
    var claimed: Double = 0.0
    var userWallet: String = ""
    var gasBalance: Double = 0.0
    var referenceBlock: Int = 0
}
