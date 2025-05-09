//
//  APIErrorHandling.swift
//  Khawi
//
//  Created by Karim Amsha on 6.11.2023.
//

import Foundation
import Alamofire

class ErrorHandling {
    func handleAPIError(_ error: APIClient.APIError) -> String {
        switch error {
        case .networkError(let afError):
            return handleNetworkError(afError)
        case .badRequest:
            return LocalizedError.badRequest
        case .unauthorized:
            return LocalizedError.unauthorized
        case .invalidData:
            return LocalizedError.invalidData
        case .decodingError(let decodingError):
            // Handle decoding errors
            return handleDecodingError(decodingError)
        case .notFound:
            return LocalizedError.resourceNotFound
        case .serverError:
            return LocalizedError.serverError
        case .invalidToken:
            return LocalizedError.invalidToken
        case .customError(message: let message):
            return message
        case .requestError(let afError):
            return handleAlamofireRequestError(afError)
        case .unknownError:
            return LocalizedError.unknownError
        }
    }

    func handleNetworkError(_ error: AFError) -> String {
        switch error {
        case .sessionTaskFailed(let sessionError as URLError):
            switch sessionError.code {
            case .notConnectedToInternet:
                return LocalizedError.noInternetConnection
            default:
                return LocalizedError.unknownError
            }
        default:
            return LocalizedError.unknownError
        }
    }
    
    private func handleAlamofireRequestError(_ afError: AFError) -> String {
        // You can handle Alamofire-specific errors here
        switch afError {
        case .invalidURL:
            return LocalizedError.invalidURL
        case .responseValidationFailed(reason: let reason):
            return "\(LocalizedError.responseValidationFailed): \(reason)"
        // Handle other Alamofire-specific errors as needed
        default:
            return LocalizedError.unknownError
        }
    }
    
    // Helper function to handle decoding errors
    private func handleDecodingError(_ decodingError: DecodingError) -> String {
        switch decodingError {
        case .dataCorrupted(let context):
            return "Data corrupted: \(context)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found: \(context)"
        case .typeMismatch(let type, let context):
            return "Type mismatch, expected \(type): \(context)"
        case .valueNotFound(let type, let context):
            return "Value not found, expected \(type): \(context)"
        default:
            return "Decoding error: \(decodingError.localizedDescription)"
        }
    }
    
    func mapAFErrorToAPIError(_ error: AFError) -> APIClient.APIError {
        switch error {
        case .invalidURL:
            return .requestError(error)
        case .parameterEncodingFailed:
            return .requestError(error)
        case .multipartEncodingFailed:
            return .requestError(error)
        case .responseValidationFailed:
            return .requestError(error)
        case .responseSerializationFailed(let reason):
            switch reason {
            case .stringSerializationFailed(let encoding):
                return .decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "String serialization failed with encoding: \(encoding)")))
            case .jsonSerializationFailed:
                return .decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "JSON serialization failed")))
            case .customSerializationFailed(let message):
                return .decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: message as? String ?? "")))
            default:
                return .networkError(error)
            }
        default:
            return .networkError(error)
        }
    }
    
    func handleStatusCode405(code: Int, errorMessage: String?, updateErrorMessage: ((String) -> Void)?, onLogout: (() -> Void)?) {
        if code == 405 {
            // Show error message for status code 405
            print("Status code 405: Method Not Allowed")
            if let message = errorMessage {
                print("Error message: \(message)")
                // You might trigger an alert or update UI to show this error message
                updateErrorMessage?(message)
            }
            // Perform logout or other necessary actions
            onLogout?()
        }
    }
}
