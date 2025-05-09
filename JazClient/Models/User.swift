import Foundation

struct User: Codable, Hashable, Identifiable {
    let createAt: String?
    let isVerify: Bool?
    let isBlock: Bool?
    let wallet: Double?
    let streetName: String?
    let floorNo: String?
    let buildingNo: String?
    let flatNo: String?
    let rate: Double?
    let by: String?
    let id: String?
    let full_name: String?
    let email: String?
    let password: String?
    let phone_number: String?
    let os: String?
    let lat: Double?
    let lng: Double?
    let fcmToken: String?
    let verify_code: String?
    let isEnableNotifications: Bool?
    let token: String?
    let image: String?
    let address: String?
    let orders: Int?
//    let delivery_address: [AddressItem]?
    let points: Int?
    let dob: String?

    enum CodingKeys: String, CodingKey {
        case createAt, isVerify, isBlock, wallet, streetName, floorNo, buildingNo, flatNo, rate, by
        case id = "_id"
        case full_name, email, password, phone_number, os, lat, lng, fcmToken
        case verify_code, isEnableNotifications, token, image, address, orders, delivery_address, points, dob
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createAt = try container.decodeIfPresent(String.self, forKey: .createAt)
        isVerify = try container.decodeIfPresent(Bool.self, forKey: .isVerify)
        isBlock = try container.decodeIfPresent(Bool.self, forKey: .isBlock)
        wallet = try container.decodeIfPresent(Double.self, forKey: .wallet)
        streetName = try container.decodeIfPresent(String.self, forKey: .streetName)
        floorNo = try container.decodeIfPresent(String.self, forKey: .floorNo)
        buildingNo = try container.decodeIfPresent(String.self, forKey: .buildingNo)
        flatNo = try container.decodeIfPresent(String.self, forKey: .flatNo)
        rate = try container.decodeIfPresent(Double.self, forKey: .rate)
        by = try container.decodeIfPresent(String.self, forKey: .by)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        full_name = try container.decodeIfPresent(String.self, forKey: .full_name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        phone_number = try container.decodeIfPresent(String.self, forKey: .phone_number)
        os = try container.decodeIfPresent(String.self, forKey: .os)
        lat = try container.decodeIfPresent(Double.self, forKey: .lat)
        lng = try container.decodeIfPresent(Double.self, forKey: .lng)
        fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken)
        verify_code = try container.decodeIfPresent(String.self, forKey: .verify_code)
        isEnableNotifications = try container.decodeIfPresent(Bool.self, forKey: .isEnableNotifications)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        orders = try container.decodeIfPresent(Int.self, forKey: .orders)
//        delivery_address = try container.decodeIfPresent([AddressItem].self, forKey: .delivery_address)
        points = try container.decodeIfPresent(Int.self, forKey: .points)
        dob = try container.decodeIfPresent(String.self, forKey: .dob)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(createAt, forKey: .createAt)
        try container.encodeIfPresent(isVerify, forKey: .isVerify)
        try container.encodeIfPresent(isBlock, forKey: .isBlock)
        try container.encodeIfPresent(wallet, forKey: .wallet)
        try container.encodeIfPresent(streetName, forKey: .streetName)
        try container.encodeIfPresent(floorNo, forKey: .floorNo)
        try container.encodeIfPresent(buildingNo, forKey: .buildingNo)
        try container.encodeIfPresent(flatNo, forKey: .flatNo)
        try container.encodeIfPresent(rate, forKey: .rate)
        try container.encodeIfPresent(by, forKey: .by)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(full_name, forKey: .full_name)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(phone_number, forKey: .phone_number)
        try container.encodeIfPresent(os, forKey: .os)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(lng, forKey: .lng)
        try container.encodeIfPresent(fcmToken, forKey: .fcmToken)
        try container.encodeIfPresent(verify_code, forKey: .verify_code)
        try container.encodeIfPresent(isEnableNotifications, forKey: .isEnableNotifications)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(orders, forKey: .orders)
//        try container.encodeIfPresent(delivery_address, forKey: .delivery_address)
        try container.encodeIfPresent(points, forKey: .points)
        try container.encodeIfPresent(dob, forKey: .dob)
    }
    
    init(fromDictionary dictionary: [String: Any]) {
        createAt = dictionary["createAt"] as? String
        isVerify = dictionary["isVerify"] as? Bool
        isBlock = dictionary["isBlock"] as? Bool
        wallet = dictionary["wallet"] as? Double
        streetName = dictionary["streetName"] as? String
        floorNo = dictionary["floorNo"] as? String
        buildingNo = dictionary["buildingNo"] as? String
        flatNo = dictionary["flatNo"] as? String
        rate = dictionary["rate"] as? Double
        by = dictionary["by"] as? String
        id = dictionary["id"] as? String
        full_name = dictionary["full_name"] as? String
        email = dictionary["email"] as? String
        password = dictionary["password"] as? String
        phone_number = dictionary["phone_number"] as? String
        os = dictionary["os"] as? String
        lat = dictionary["lat"] as? Double
        lng = dictionary["lng"] as? Double
        fcmToken = dictionary["fcmToken"] as? String
        verify_code = dictionary["verify_code"] as? String
        isEnableNotifications = dictionary["isEnableNotifications"] as? Bool
        token = dictionary["token"] as? String
        image = dictionary["image"] as? String
        address = dictionary["address"] as? String
        orders = dictionary["orders"] as? Int
//        delivery_address = dictionary["delivery_address"] as? [AddressItem]
        points = dictionary["points"] as? Int
        dob = dictionary["dob"] as? String
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var formattedDOB: String? {
        guard let dateString = dob else {
            return nil
        }
        return formatDateToString(createDateFromString(dateString, format: "yyyy-MM-dd") ?? Date(), format: "yyyy-MM-dd")
    }
    
    // Convert date string to Date with specific format
    private func createDateFromString(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
    
    // Convert Date to date string with specific format
    private func formatDateToString(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
