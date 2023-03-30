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
import CodableWrapper

public struct DIDListResponse: Decodable {
    
    @Codec
    public var data: [String] = []
}

public class DIDClient {
    
    public static func getDIDList(address: String, completion: @escaping(Result<DIDListResponse?,MoyaError>) -> ()) {
        APIProvider<DIDAPI,DIDListResponse>.request(.getDidList(address)) { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


