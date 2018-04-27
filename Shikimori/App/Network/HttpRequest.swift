//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class HttpRequest<T>: Request {

    let urlRequest: URLRequest
    let urlSession: URLSession
    let mapper: HttpMapper<T>
    let errorMapper: HttpMapper<AppError>

    private (set) var promise: Promise<T>?
    private var dataTask: URLSessionDataTask?

    init(urlRequest: URLRequest, mapper: HttpMapper<T>, errorMapper: HttpMapper<AppError>, urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlRequest = urlRequest
        self.mapper = mapper
        self.errorMapper = errorMapper
        self.urlSession = urlSession
    }

    func load() -> Promise<T> {
        let promise = Promise<T>()
        let handler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                let appError = AppError.network(underlyingError: error)
                promise.reject(appError)
                return
            }
            if let data = data {
                if let result: T = try? self.mapper.decode(data) {
                    promise.fulfill(result)
                    return
                }
                if let result: AppError = try? self.errorMapper.decode(data) {
                    promise.reject(result)
                    return
                }
            }
            promise.reject(AppError.fatal(data: data, response: (response as! HTTPURLResponse)))
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
