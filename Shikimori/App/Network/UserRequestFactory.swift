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


class UserByIDRequestFactory: EndpointRequestFactory {

    func getUser(byID userID: Int, session: Session) -> HttpRequest<User> {

        let request: URLRequest = requestFactory.request(.GET,
                url: urlBuilder.url(withPath: "/api/users/\(userID)"),
                accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: UserByIDRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}


class UserByIDRequestResultMapper: DefaultNetworkRequestResultMapper<UserResult, User> {

    init() {
        super.init(converter: UserSalToDomainConverter())
    }
}


fileprivate class UserSalToDomainConverter: SalToDomainConverter<UserResult, User> {

    override func convert(_ result: UserResult) throws -> User {
        let stats = result.stats != nil ? self.userStatsFromResult(result.stats!) : nil // TODO [investigate] there should exist more swift way to write this kind of expressions

        return User(id: result.id,
                nickname: result.nickname,
                avatar: result.avatar != nil ? URL(string: result.avatar!) : nil,
                stats: stats)
    }

    private func userStatsFromResult(_ stats: UserResult.StatsResult) -> UserStatistics? {
        guard let result: UserResult.StatsResult.StatusesResult = stats.statuses else {
            return  nil
        }
        return UserStatistics(
                anime: result.anime != nil ? userStatisticsFromStatusesResult(result.anime!) : nil,
                manga: result.manga != nil ? userStatisticsFromStatusesResult(result.manga!) : nil)
    }


    typealias StatResult = UserResult.StatsResult.StatusesResult.StatResult
    private func userStatisticsFromStatusesResult(_ statuses: [StatResult]) -> UserStatistics.Statistics? {
        return UserStatistics.Statistics(
                planned: stat("planned", fromStatsDescription: statuses),
                watching: stat("watching", fromStatsDescription: statuses),
                completed: stat("completed", fromStatsDescription: statuses),
                onHold: stat("on_hold", fromStatsDescription: statuses),
                dropped: stat("dropped", fromStatsDescription: statuses))

    }

    private func stat(_ type: String, fromStatsDescription statsDescription: [StatResult]) -> Int {
        let stat: [StatResult] = statsDescription.filter { $0.name == type }
        return stat.first?.size ?? 0
    }

}