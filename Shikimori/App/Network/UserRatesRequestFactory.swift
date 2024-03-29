//
// Created by Aziz Latipov on 18.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct UserRatesResult: Codable {

    let targetId: Int
    let targetType: String

}

class UserRatesRequestFactory: EndpointRequestFactory {

    func getUserRates(byID userID: Int,
                      status: UserRates.Status,
                      targetType: UserRates.TargetType,
                      session: Session) -> HttpRequest<[UserRates]> {

        let url = urlBuilder.url(withPath: "/api/v2/user_rates", queryItems: [
            URLQueryItem(name: "user_id", value: "\(userID)"),
            URLQueryItem(name: "target_type", value: targetType.rawValue),
            URLQueryItem(name: "status", value: status.rawValue),
        ])! // swiftlint:disable:this force_unwrapping

        let request: URLRequest = requestFactory.get(url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: UserRatesRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}

class UserRatesRequestResultMapper: DefaultNetworkRequestResultMapper<[UserRatesResult], [UserRates]> {

    override func convert(_ result: [UserRatesResult]) throws -> [UserRates] {
        return result.map {
            // swiftlint:disable:next force_unwrapping
            let targetType = UserRates.TargetType(rawValue: $0.targetType)!
            return UserRates(targetId: $0.targetId, targetType: targetType)
        }
    }

}
