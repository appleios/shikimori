//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class HttpRequest<T>: Request {

    let urlRequest: URLRequest
    let mapper: HttpMapper<T>
    let session: URLSession

    private (set) var promise: Promise<T>?
    private var dataTask: URLSessionDataTask?

    init(urlRequest: URLRequest, mapper: HttpMapper<T>, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlRequest = urlRequest
        self.mapper = mapper
        self.session = session
    }

    func load() -> Promise<T> {
        let promise = Promise<T>()
        let handler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                promise.reject(error) // TODO enrich error with HTTP Status Code
                return
            }
            if let data = data {
                if let result = try? self.mapper.decode(data) {
                    promise.fulfill(result)
                    return
                }
            }
        }

        let dataTask: URLSessionDataTask = self.session.dataTask(with: self.urlRequest, completionHandler: handler)
        dataTask.resume()

        self.promise = promise
        self.dataTask = dataTask
        return getPromise()!
    }

    func cancel() {
        self.promise?.cancel()
        self.dataTask?.cancel()
    }

    func getPromise() -> Promise<T>? {
        guard let promise = promise else { return nil }

        let p = Promise<T>()
        promise.chain(p)
        return p
    }
}
