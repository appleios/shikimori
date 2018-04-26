//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class HttpRequest<T>: Request {

    let urlRequest: URLRequest
    let session: URLSession

    private (set) var promise: Promise<T>?
    private var dataTask: URLSessionDataTask?

    init(urlRequest: URLRequest, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlRequest = urlRequest
        self.session = session
    }

    func execute() {
        let promise = Promise<T>()
        let handler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                promise.reject(error) // TODO enrich error with HTTP Status Code
                return
            }
            if let data = data as? T {
                promise.fulfill(data)
                return
            }
        }

        self.promise = promise
        self.dataTask = self.session.dataTask(with: self.urlRequest, completionHandler: handler)
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
