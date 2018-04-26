//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class HttpRequest<T>: Request {

    let urlRequest: URLRequest
    let urlSession: URLSession
    let mapper: HttpMapper<T>

    private (set) var promise: Promise<T>?
    private var dataTask: URLSessionDataTask?

    init(urlRequest: URLRequest, mapper: HttpMapper<T>, urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlRequest = urlRequest
        self.mapper = mapper
        self.urlSession = urlSession
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
            // TODO reject with error decoded from json
        }

        let dataTask: URLSessionDataTask = self.urlSession.dataTask(with: self.urlRequest, completionHandler: handler)
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
