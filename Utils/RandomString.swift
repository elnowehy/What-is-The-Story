//
//  RandomString.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-12.
//

import Foundation

// length in firebase is 28 characters.
func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

