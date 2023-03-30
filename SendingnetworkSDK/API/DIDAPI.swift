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

import Foundation
import Moya

///DID
enum DIDAPI {
    
    case getDidList(String)
    
    case getDidDetail(String)
    
    case createDid(String)
    
    case saveDid(String,Parameters)
    
    case updateDid(String,Parameters)
    
    case preLogin(String)
    
    case didLogin(Parameters)
    
    case analysisDid(String)
    
}

extension DIDAPI: Moya.TargetType {
    
    var path: String {
        switch self{
        case .getDidList(let address):
            return "/_api/client/unstable/address/\(address)"
        case .getDidDetail(let did):
            return "/_api/client/unstable/did/\(did)/detail"
        case .createDid:
            return "/_api/client/unstable/did/create"
        case .saveDid(let did, _):
            return "/_api/client/unstable/did/\(did)"
        case .updateDid(let did, _):
            return "/_api/client/unstable/did/\(did)/update"
        case .preLogin(let did):
            return "/_api/client/unstable/did/\(did)/pre_login"
        case .didLogin:
            return "/_api/client/unstable/did/login"
        case .analysisDid(let did):
            return "/_api/client/unstable/did/\(did)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getDidList:
            return .get
        case .getDidDetail:
            return .get
        case .createDid:
            return .post
        case .saveDid:
            return .post
        case .updateDid:
            return .post
        case .preLogin:
            return .post
        case .didLogin:
            return .post
        case .analysisDid:
            return.get
        }
    }
    
    var task: Task {
        switch self {
        case .getDidList:
            return .requestPlain
        case .getDidDetail:
            return .requestPlain
        case .createDid(let address):
            return .requestParameters(parameters: ["address": "did:pkh:eip155:1:" + address], encoding: JSONEncoding.default)
        case .saveDid(_, let did):
            return .requestParameters(parameters: ["did": did], encoding: JSONEncoding.default)
        case .updateDid( _, let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .preLogin(let did):
            return .requestParameters(parameters: ["did": did], encoding: JSONEncoding.default)
        case .didLogin(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .analysisDid:
            return .requestPlain
        }
    }
}
