//
//  AlertModel.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation

struct AlertModel: Hashable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let hasItem: Bool
    let item: String?
    let okTitle: String
    let cancelTitle: String
    let hidesIcon: Bool
    let hidesCancel: Bool
    let onOKAction: (() -> Void)?
    let onCancelAction: (() -> Void)?
    
    // Hash function using unique identifier
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Equatable function
    static func == (lhs: AlertModel, rhs: AlertModel) -> Bool {
        return lhs.id == rhs.id
    }
}

import Foundation

struct AlertModelWithInput: Hashable, Equatable {
    let title: String
    let content: String
    let hideCancelButton: Bool
    let onOKAction: (String) -> Void
    let onCancelAction: () -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }

    static func == (lhs: AlertModelWithInput, rhs: AlertModelWithInput) -> Bool {
        return lhs.content == rhs.content
    }
}

struct DateTimeModel: Hashable, Equatable {
    let pickerMode: DateTimePickerMode
    let onOKAction: (Date) -> Void
    let onCancelAction: () -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pickerMode)
    }

    static func == (lhs: DateTimeModel, rhs: DateTimeModel) -> Bool {
        return lhs.pickerMode == rhs.pickerMode
    }
}
