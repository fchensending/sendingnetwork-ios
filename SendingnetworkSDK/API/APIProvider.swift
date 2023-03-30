// 
// Copyright 2023 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Moya
import UIKit
import Combine
import RxSwift
import Alamofire
import Foundation

typealias Empty = Alamofire.Empty
public typealias MoyaError = Moya.MoyaError
typealias ProgressBlock = Moya.ProgressBlock

typealias Parameters = [String: Any]
typealias HeaderFields = [String: String]

let requestClosure = { (endpoint: Endpoint, closure: @escaping MoyaProvider<MultiTarget>.RequestResultClosure) in
    do {
        var urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 30
        closure(.success(urlRequest))
    } catch MoyaError.statusCode(let response) {
        closure(.failure(MoyaError.statusCode(response)))
    }  catch MoyaError.requestMapping(let url) {
        closure(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        closure(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
}

#if DEBUG
let provider = MoyaProvider<MultiTarget>(requestClosure: requestClosure, plugins: [NetworkLoggerPlugin.custom])
#else
let provider = MoyaProvider<MultiTarget>(requestClosure: requestClosure)
#endif

struct APIProvider<Target: Moya.TargetType, T: Decodable> {

    typealias Completion = (Result<T?, MoyaError>) -> Void
    
    @discardableResult
    static func request(_ target: Target, completion: @escaping Completion) -> Disposable {
        provider.rx.request(MultiTarget(target)).subscribe { event in
            switch event {
            case let .success(response):
                handleSuccess(response, target: target, completion: completion)
            case let .failure(error):
                handleFailure(error, completion: completion)
            }
        }
    }
    
    
    /// - Parameters:
    ///   - response: response
    ///   - completion: completion
    static func handleSuccess(_ response: Moya.Response, target: Target, completion: @escaping Completion) {
        do {
            let value = try response.map(T.self)
            if response.statusCode == 200 {
                completion(.success(value))
            } else {
                debugPrint("error  occured  message  \(response.description)")
                completion(.failure(.requestMapping(response.description)))
            }
        } catch {
            completion(.failure(.encodableMapping(error)))
            debugPrint("""
            Error Occured!!!
            URL: \(response.request?.url?.absoluteString ?? "")
            Data: \(String(describing: String(data: response.data, encoding: .utf8)))
            Desc: \(error.localizedDescription)
            """)
        }
    }
    
    /// - Parameters:
    ///   - response: response
    ///   - completion: completion
    static func handleFailure(_ error: Error, completion: @escaping Completion) {
        completion(.failure(.underlying(error, nil)))
    }
    
}

extension MoyaError {
    
    /// https://github.com/Alamofire/Alamofire/issues/3145
    var errorDescription: String? {
        switch self {
        case .imageMapping:
            return "Failed to map data to an Image."
        case .jsonMapping:
            return "Failed to map data to JSON."
        case .stringMapping:
            return "Failed to map data to a String."
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        case .encodableMapping:
            return "Failed to encode Encodable object into data."
        case .statusCode:
            return "Status code didn't fall within the given range."
        case .underlying(let error, _):
            return error.localizedDescription
        case .requestMapping:
            return "Failed to map Endpoint to a URLRequest."
        case .parameterEncoding(let error):
            return "Failed to encode parameters for URLRequest. \(error.localizedDescription)"
        }
    }
    
}

extension ObservableType {
    func subscribed(onNext: ((Element) -> Void)? = nil) -> Disposable {
        subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
    }
}

extension SingleEvent {
    /// Returns the associated value if the result is a success, `nil` otherwise.
    var element: Success? {
        guard case let .success(element) = self else { return nil }
        return element
    }
}

extension Result {
    /// Returns whether the instance is `.success`.
    var isSuccess: Bool {
        guard case .success = self else { return false }
        return true
    }

    /// Returns whether the instance is `.failure`.
    var isFailure: Bool {
        !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    var success: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var failure: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}

extension NetworkLoggerPlugin.Configuration.LogOptions {
    static let custom: NetworkLoggerPlugin.Configuration.LogOptions = [
        requestBody,
        requestMethod,
        requestHeaders,
        errorResponseBody,
        successResponseBody,
    ]
}

extension NetworkLoggerPlugin {
    /// Returns the default verbose logger plugin
    class var custom: NetworkLoggerPlugin {
        return NetworkLoggerPlugin(configuration: Configuration(logOptions: .custom))
    }
}


extension Moya.TargetType {
    var baseURL: URL {
        return URL(string: "http://localhost:65432")!
    }
    
    var method: Moya.Method {
        .get
    }
    
    var headers: HeaderFields? {
        APIHeader().headers
    }
    
    var task: Task {
        .requestPlain
    }
}

extension String {
    
    func model<T>(_ type: T.Type) -> T? where T : Decodable {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            debugPrint(error)
        }
        return nil
    }
     
    
    func models<T>(_ type: T.Type) -> [T] where T : Decodable {
        guard let data = data(using: .utf8) else { fatalError() }
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            debugPrint(error)
        }
        return []
    }
    
}

extension Encodable {
    
    var headers: HeaderFields {
        do {
            let data = try JSONEncoder().encode(self)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard JSONSerialization.isValidJSONObject(object) else {
                return [:]
            }
            guard let headers = object as? HeaderFields else {
                return [:]
            }
            return headers
        } catch {
            return [:]
        }
    }
    
    var parameters: Parameters {
        do {
            let data = try JSONEncoder().encode(self)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard JSONSerialization.isValidJSONObject(object) else {
                return [:]
            }
            guard let parameters = object as? Parameters else {
                return [:]
            }
            return parameters
        } catch {
            return [:]
        }
    }
    
    @discardableResult
    func merging(_ new: Encodable) -> Parameters {
        parameters.merging(new.parameters) { (old, new) in new }
    }

}

extension Dictionary where Key == String {
    
    /// - Parameter new:
    mutating func merge(_ new: Self) {
        merge(new) { (old, new) in new }
    }
    
    func merging(_ new: Self) -> Self {
        merging(new) { (old, new) in new }
    }
    
    @discardableResult
    mutating func update(_ value: Value, forKey key: Key) -> Self {
        updateValue(value, forKey: key)
        return self
    }
    
    @discardableResult
    mutating func update(_ new: Self) -> Self {
        new.forEach { (key, value) in
            updateValue(value, forKey: key)
        }
        return self
    }
    
}

struct APIHeader: Encodable {
    
    var authToken = "Bearer " + (SDNBaseSetting.shared.accessToken ?? "")
    
    private enum CodingKeys: String, CodingKey {
        case authToken = "Authorization"
    }
}
