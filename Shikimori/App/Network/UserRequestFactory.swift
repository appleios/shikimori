//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class UserRequestFactory: EndpointRequestFactory {

    func getUser(session: Session, userID: Int) -> HttpRequest<User> {

        let components = urlFactory.components(withPath: "/api/users/\(userID)")
        let request: URLRequest = requestFactory.request(.GET, url: components.url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: UserMapper(jsonDecoder: jsonDecoder),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}


class UserMapper: HttpMapper<User> {

    struct UserResult: Codable {

        var id: Int
        var nickname: String
        var avatar: String

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

    let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
        super.init()
    }

    override func decode(_ data: Data) throws -> User {
        let result = try jsonDecoder.decode(UserResult.self, from: data)
        let stats = result.stats != nil ? self.userStatsFromResult(result.stats!) : nil // TODO [investigate] there should exist more swift way to write this kind of expressions

        return User(id: result.id,
                nickname: result.nickname,
                avatar: URL(string: result.avatar)!,
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
