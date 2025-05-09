//
//  CustomModel.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation

struct CustomModel<T: Hashable>: Hashable, Equatable {
    let title: String
    let content: String
    let items: [T]
    let onSelect: (T) -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }

    static func == (lhs: CustomModel<T>, rhs: CustomModel<T>) -> Bool {
        return lhs.content == rhs.content
    }
}

struct MyCustomModel<T: Hashable>: Hashable, Equatable {
    let title: String
    let content: String
    let items: [T]
    let onSelect: (T) -> Void
    let selectPublic: (Bool) -> Void

    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }

    static func == (lhs: MyCustomModel<T>, rhs: MyCustomModel<T>) -> Bool {
        return lhs.content == rhs.content
    }
}
