//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct UserResult: Codable {

    var id: Int
    var nickname: String
    var avatar: String?

    struct StatsResult: Codable {

        struct StatusesResult: Codable {

            struct StatResult: Codable {
                var name: String
                var size: Int
            }

            var anime: [StatResult]?
            var manga: [StatResult]?
        }

        var statuses: StatusesResult?
    }

    var stats: StatsResult?
}

class UserRequestFactory: EndpointRequestFactory {

    func getUser(byID userID: Int, session: Session) -> HttpRequest<User> {

        let request: URLRequest = requestFactory.get(urlBuilder.url(withPath: "/api/users/\(userID)"),
                accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: UserRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}

class UserRequestResultMapper: DefaultNetworkRequestResultMapper<UserResult, User> {

    init() {
        super.init(converter: UserSalToDomainConverter())
    }
}

private class UserSalToDomainConverter: SalToDomainConverter<UserResult, User> {

    override func convert(_ result: UserResult) throws -> User {
        let stats = userStatsFromResult(result.stats) // TODO [investigate] there should exist more swift way to write this kind of expressions

        return User(id: result.id,
                nickname: result.nickname,
                avatar: result.avatar != nil ? URL(string: result.avatar!) : nil,
                stats: stats)
    }

    private func userStatsFromResult(_ stats: UserResult.StatsResult?) -> UserStatistics? {
        guard let stats = stats else {
            return nil
        }
        guard let result: UserResult.StatsResult.StatusesResult = stats.statuses else {
            return  nil
        }
        return UserStatistics(
                anime: userStatisticsFromStatusesResult(result.anime),
                manga: userStatisticsFromStatusesResult(result.manga))
    }

    typealias StatResult = UserResult.StatsResult.StatusesResult.StatResult
    private func userStatisticsFromStatusesResult(_ statuses: [StatResult]?) -> UserStatistics.Statistics? {
        guard let statuses = statuses else {
            return nil
        }

        var statistics = UserStatistics.Statistics()
        for statusRaw in statuses {
            if let status = UserRates.Status(rawValue: statusRaw.name) {
                statistics[status] = statusRaw.size
            }
        }
        return statistics

    }

    private func stat(_ status: UserRates.Status, fromStatsDescription statsDescription: [StatResult]) -> Int {
        let stat: [StatResult] = statsDescription.filter { $0.name == status.rawValue }
        return stat.first?.size ?? 0
    }

}
