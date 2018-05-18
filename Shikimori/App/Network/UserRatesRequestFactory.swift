//
// Created by Aziz Latipov on 18.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


enum UserRatesStatus: String {
    case planned
    case watching
    case rewatching
    case completed
    case onHold = "on_hold"
    case dropped
}


enum UserRatesTargetType: String {
    case anime = "Anime"
    case manga = "Manga"
}


struct UserRates {

    let targetId: Int
    let targetType: UserRatesTargetType

}


struct UserRatesResult: Codable {

    let targetId: Int
    let targetType: String

}


class UserRatesRequestFactory: EndpointRequestFactory {

    func getUserRates(byID userID: Int,
                      status: UserRatesStatus,
                      targetType: UserRatesTargetType,
                      session: Session) -> HttpRequest<[UserRates]>
    {

        let url = urlBuilder.url(withPath: "/api/v2/user_rates", queryItems: [
            URLQueryItem(name: "user_id", value: "\(userID)"),
            URLQueryItem(name: "target_type", value: targetType.rawValue),
            URLQueryItem(name: "status", value: status.rawValue)
        ])

        let request: URLRequest = requestFactory.get(url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: UserRatesRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}


class UserRatesRequestResultMapper: DefaultNetworkRequestResultMapper<[UserRatesResult], [UserRates]> {

    init() {
        super.init(converter: ClosureSalToDomainConverter({ (result: [UserRatesResult]) in
            return result.map {
                return UserRates(targetId: $0.targetId,
                        targetType: UserRatesTargetType(rawValue: $0.targetType)!)
            }
         }))
    }

}
