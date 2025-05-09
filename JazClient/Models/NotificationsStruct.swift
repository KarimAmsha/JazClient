//
//  NotificationsStruct.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import UIKit
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationsStruct: Codable, Identifiable, Hashable {
    
    static func == (lhs: NotificationsStruct, rhs: NotificationsStruct) -> Bool {
        return lhs.id == rhs.id
    }

    var id             : String
    let type           : NotifiType?
    let title          : String
    var message        : String
    var timestamp: Int64? = Date().toMillis()
    let eventKey       : String
    let receiverId     : String
    let senderId       : String
    let isAccepted     : Bool
    let url            : String

    var dictionary: [String: Any] {
        return [
            "id": id,
            "type": type?.value ?? "",
            "title": title,
            "message": message,
            "timestamp": timestamp ?? Date().toMillis(),
            "eventKey": eventKey,
            "receiverId": receiverId,
            "senderId": senderId,
            "isAccepted": isAccepted,
            "url": url,
        ]
    }

    init(id:String, type: NotifiType, title: String,
          message: String, eventKey: String,
         receiverId: String, senderId: String, isAccepted: Bool, url: String) {
        self.id               = id
        self.type             = type
        self.title            = title
        self.message          = message
        self.eventKey         = eventKey
        self.receiverId       = receiverId
        self.senderId         = senderId
        self.isAccepted       = isAccepted
        self.url              = url
    }
    
    init(_ document: DocumentSnapshot?) {
        let data       = document?.data()
        id             = data?["id"] as? String ?? ""
        type           = NotifiType(data?["type"] as? String ?? "")
        title          = data?["title"] as? String ?? ""
        message        = data?["message"] as? String ?? ""
        timestamp      = data?["timestamp"] as? Int64 ?? 0
        eventKey       = data?["eventKey"] as? String ?? ""
        receiverId     = data?["receiverId"] as? String ?? ""
        senderId       = data?["senderId"] as? String ?? ""
        isAccepted     = data?["isAccepted"] as? Bool ?? false
        url            = data?["url"] as? String ?? ""
    }

    func toDict() -> [String:Any] {
        return [
            "type"          : self.type?.value ?? "",
            "title"         : self.title,
            "message"       : self.message,
            "eventKey"      : self.eventKey,
            "receiverId"    : self.receiverId,
            "senderId"      : self.senderId,
            "isAccepted"    : self.isAccepted,
            "url"           : self.url
        ]
    }
}
