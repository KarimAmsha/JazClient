//
//  APIClient.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation
import Alamofire
import Combine

class APIClient {
    static let shared = APIClient()
    private var activeRequest: DataRequest?
    
    // MARK: Error Handling
    enum APIError: Error {
        case networkError(AFError)
        case invalidData
        case decodingError(DecodingError)
        case requestError(AFError)
        case unauthorized
        case notFound
        case badRequest
        case serverError
        case invalidToken
        case customError(message: String)
        case unknownError
    }

    // MARK: Common Request Function
    private func performRequest<T: Decodable>(
        for endpoint: APIEndpoint,
        with publisher: DataRequest
    ) -> AnyPublisher<T, APIError> {
        return publisher
            .publishData()
            .tryMap { response in
                if let data = response.data {
                    return data
                } else {
                    throw APIError.invalidData
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                self.mapDecodingError(error)
            }
            .receive(on: DispatchQueue.main) // You can add this to ensure the result is on the main thread
            .eraseToAnyPublisher()
    }
}

// MARK: Request Functions
extension APIClient {
    func request<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (Result<T, APIError>) -> Void) {
        activeRequest = AF.request(endpoint.fullURL, method: endpoint.method, parameters: endpoint.parameters, headers: endpoint.headers)
            .validate()
            .response { response in
                self.decodeApiResponse(response: response, completion: completion)
            }
    }
    
    func requestPublisher<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        let dataRequest = AF.request(endpoint.fullURL, method: endpoint.method, parameters: endpoint.parameters, headers: endpoint.headers)
        
        return performRequest(for: endpoint, with: dataRequest)
    }
    
    func sendData(
        endpoint: APIEndpoint,
        completion: @escaping (Result<Any, AFError>) -> Void
    ) {
        AF.request(endpoint.fullURL, method: .post, parameters: endpoint.parameters, encoding: JSONEncoding.default, headers: endpoint.headers)
            .validate()
            .responseJSON { response in
                completion(response.result)
            }
    }

    func createRequest(endpoint: APIEndpoint, requestInfo: [String :String], completion: @escaping (_ result: String) -> Void){
                
        let parameters: [String : Any] = ["request" : JSONToString(json : requestInfo)!]
        
        AF.request(endpoint.fullURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseString { response in
            print(response)
            
        }
    }
    
    func JSONToString(json: [String : String]) -> String?{
        do {
            let mdata =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // json to the data
            let convertedString = String(data: mdata, encoding: String.Encoding.utf8) // the data will be converted to the string
            print("the converted json to string is : \(convertedString!)") // <-- here is ur string

            return convertedString!

        } catch let myJSONError {
            print(myJSONError)
        }
        return ""
    }

    func requestMultipartPublisherWithProgress<T: Decodable>(endpoint: APIEndpoint, imageFiles: [(Data, String)]?) -> AnyPublisher<(T, Double), APIError> {
        return Future { promise in
            var request = AF.upload(multipartFormData: { multipartFormData in
                self.createMultipartFormData(
                    multipartFormData: multipartFormData,
                    imageFiles: imageFiles,
                    parameters: endpoint.parameters
                )
            }, to: endpoint.fullURL, headers: endpoint.headers)
                        
            let progressSubject = PassthroughSubject<Double, Never>() // Create a subject for progress updates

            request = request.uploadProgress(closure: { progress in
                let uploadProgress = progress.fractionCompleted
                progressSubject.send(uploadProgress) // Send progress updates
            })
            
            request.responseDecodable(of: T.self, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    promise(.success((value, 1.0))) // Progress completed when the response is successful
                case .failure(let error):
                    promise(.failure(APIError.requestError(error)))
                }
            }
            
            var cancellable: AnyCancellable?
            cancellable = progressSubject.sink { progress in
                // You can access the progress updates here
                // For example, you can update your UI with the current progress
                let formatter = NumberFormatter()
                formatter.numberStyle = .percent
                formatter.maximumFractionDigits = 1
                if let formattedProgress = formatter.string(from: NSNumber(value: progress)) {
                    print("Upload Progress: \(formattedProgress)")
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // Helper method to create multipart form data
    private func createMultipartFormData(multipartFormData: MultipartFormData, imageFiles: [(Data, String)]?, parameters: [String: Any]?) {
        if let imageFiles = imageFiles {
            for (imageData, fieldName) in imageFiles {
                multipartFormData.append(imageData, withName: fieldName, fileName: "image.jpg", mimeType: "image/jpeg")
            }
        }

        if let parameters = parameters {
            for (key, value) in parameters {
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }
    }

    func requestMultipartPublisher<T: Decodable>(endpoint: APIEndpoint, imageFiles: [(Data, String)]?) -> AnyPublisher<T, APIError> {
        return Future { promise in
            AF.upload(
                multipartFormData: { multipartFormData in
                    if let imageFiles = imageFiles {
                        for (imageData, fieldName) in imageFiles {
                            multipartFormData.append(imageData, withName: fieldName, fileName: "image.jpg", mimeType: "image/jpeg")
                        }
                    }
                    
                    // Add other fields as needed
                    if let parameters = endpoint.parameters {
                        for (key, value) in parameters {
                            if let data = "\(value)".data(using: .utf8) {
                                multipartFormData.append(data, withName: key)
                            }
                        }
                    }
                },
                to: endpoint.fullURL,
                headers: endpoint.headers
            )
            .uploadProgress(closure: { progress in
                // You can handle upload progress here
                print("Upload Progress: \(progress.fractionCompleted * 100)%")
            })
            .responseDecodable(of: T.self, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let value):
                    if response.response?.statusCode == 200 {
                        promise(.success(value))
                    } else if response.response?.statusCode == 400 {
                        promise(.failure(APIError.badRequest))
                    } else if response.response?.statusCode == 500 {
                        promise(.failure(APIError.serverError))
                    } else {
                        promise(.failure(APIError.customError(message: LocalizedError.unknownError)))
                    }
                case .failure(let error):
                    promise(.failure(APIError.requestError(error)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

extension APIClient {
    // MARK: Cancel Request
    func cancelRequest() {
        activeRequest?.cancel()
    }
}

extension APIClient {
    private func decodeApiResponse<T: Decodable>(
        response: AFDataResponse<Data?>,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let statusCode = response.response?.statusCode ?? 0
                switch statusCode {
                case 200:
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                case 400:
                    completion(.failure(.badRequest))
                case 401:
                    completion(.failure(.unauthorized))
                case 404:
                    completion(.failure(.notFound))
                case 430:
                    completion(.failure(.invalidToken))
                case 500...599:
                    completion(.failure(.serverError))
                default:
                    // If there's a decoding error, catch it and handle it appropriately
                    do {
                        _ = try JSONDecoder().decode(T.self, from: data)
                    } catch let decodingError as DecodingError {
                        let mappedError = mapDecodingError(decodingError)
                        completion(.failure(mappedError))
                        return
                    } catch {
                        // If it's not a DecodingError, handle it as an unknown error
                        completion(.failure(.customError(message: LocalizedError.unknownError)))
                        return
                    }
                }
            } catch {
                // Handle decoding errors
                let apiError: APIError
                if let decodingError = error as? DecodingError {
                    let mappedError = mapDecodingError(decodingError)
                    completion(.failure(mappedError))
                } else {
                    apiError = .unknownError
                    completion(.failure(apiError))
                }
            }
        case .failure(let error):
            completion(.failure(.networkError(error)))
        }
    }
    
    // Helper function to map decoding errors
    func mapDecodingError(_ error: Error) -> APIError {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .dataCorrupted(let context):
                return .customError(message: "Data corrupted: \(context)")
            case .keyNotFound(let key, let context):
                return .customError(message: "Key '\(key.stringValue)' not found: \(context)")
            case .typeMismatch(let type, let context):
                return .customError(message: "Type mismatch, expected \(type): \(context)")
            case .valueNotFound(let type, let context):
                return .customError(message: "Value not found, expected \(type): \(context)")
            default:
                return .decodingError(decodingError)
            }
        } else {
            return .unknownError
        }
    }
}
