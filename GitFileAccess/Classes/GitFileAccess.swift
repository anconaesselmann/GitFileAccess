//  Created by Axel Ancona Esselmann on 3/11/20.
//  Copyright © 2020 Axel Ancona Esselmann. All rights reserved.

import RxLoadableResult
import LoadableResult
import RxSwift

public protocol GitFileAccessProtocl {
    func data(for resource: String) -> LoadingObservable<Data>
}

public enum GitFileAccessError: Swift.Error {
    case invalidUrl
    case dataTaskError(Swift.Error)
    case emptyData
    case couldNotDecode
}

extension GitFileAccessProtocl {
    public func object<Decoded>(for resource: String, decodeAs type: Decoded.Type, decoder: JSONDecoder = JSONDecoder()) -> LoadingObservable<Decoded> where Decoded : Decodable {
        data(for: resource).mapLoadableResult { data -> LoadableResult<Decoded> in
            do {
                let decoded = try decoder.decode(type, from: data)
                return .loaded(decoded)
            } catch {
                return .error(GitFileAccessError.couldNotDecode)
            }
        }
    }
}

public struct GitFileAccess: GitFileAccessProtocl {

    let accountName: String
    let repoName: String
    let accessToken: String
    let branch: String

    public init(accountName: String, repoName: String, accessToken: String, branch: String? = nil) {
        self.accountName = accountName
        self.repoName = repoName
        self.accessToken = accessToken
        self.branch = branch ?? "master"
    }

    public func data(for resource: String) -> LoadingObservable<Data> {
        guard let url = URL(string: "https://raw.githubusercontent.com/\(accountName)/\(repoName)/\(branch)/\(resource)") else {
            return .just(.error(GitFileAccessError.invalidUrl))
        }
        var request = URLRequest(url: url)
        request.addValue("raw.githubusercontent.com", forHTTPHeaderField: "Host")
        let authData = accessToken.data(using: .ascii)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.addValue(authValue, forHTTPHeaderField: "Authorization")

        return .create { subscriber -> Disposable in
            subscriber.onNext(.loading)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    subscriber.onNext(.error(GitFileAccessError.dataTaskError(error)))
                    return
                }

                guard let data = data else {
                    subscriber.onNext(.error(GitFileAccessError.emptyData))
                    return
                }
                subscriber.onNext(.loaded(data))
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
