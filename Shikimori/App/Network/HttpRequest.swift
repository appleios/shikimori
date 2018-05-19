//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class HttpRequest<DomainType>: NetworkRequest {

    let urlRequest: URLRequest
    let urlSession: URLSession
    let mapper: NetworkRequestResultMapper<DomainType>
    let errorMapper: AppErrorMapper

    private var promise: Promise<DomainType>?
    private weak var task: URLSessionTask?

    init(urlRequest: URLRequest,
         mapper: NetworkRequestResultMapper<DomainType>,
         errorMapper: AppErrorMapper,
         urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default))
    {
        self.urlRequest = urlRequest
        self.mapper = mapper
        self.errorMapper = errorMapper
        self.urlSession = urlSession
    }

    func load() throws -> Promise<DomainType> {
        guard !isLoading() else {
            throw NetworkRequestError.alreadyLoading
        }

        let promise = Promise<DomainType>()
        let handler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                let appError = AppError.network(underlyingError: error)
                promise.reject(appError)
                return
            }
            if let data = data {
                do {
                    let result: DomainType = try self.mapper.mapToDomain(data)
                    promise.fulfill(result)
                    return
                } catch {
                    let contents: String? = String(data: data, encoding: .utf8)
                    print("unexpected error: \(error), while mapToDomain for data: \(contents!)")
                }
                if let result: AppError = try? self.errorMapper.decode(data) {
                    promise.reject(result)
                    return
                }
            }
            promise.reject(AppError.fatal(data: data, response: (response as! HTTPURLResponse)))
        }

        let task: URLSessionDataTask = self.urlSession.dataTask(with: self.urlRequest, completionHandler: handler)
        task.resume()

        self.promise = promise
        self.task = task
        return promise.chained
    }

    func isLoading() -> Bool {
        return self.task != nil
    }

    func cancel() {
        self.task?.cancel()
    }

    func getResult() -> Promise<DomainType>? {
        return self.promise?.chained
    }
}
