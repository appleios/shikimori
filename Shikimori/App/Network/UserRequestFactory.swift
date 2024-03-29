//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

// swiftlint:disable nesting discouraged_optional_collection
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
// swiftlint:enable nesting discouraged_optional_collection

class UserRequestFactory: EndpointRequestFactory {

    func getUser(byID userID: Int, session: Session) -> HttpRequest<User> {

        let url = urlBuilder.url(withPath: "/api/users/\(userID)")! // swiftlint:disable:this force_unwrapping
        let request: URLRequest = requestFactory.get(url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: UserRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}

class UserRequestResultMapper: DefaultNetworkRequestResultMapper<UserResult, User> {

    override func convert(_ result: UserResult) throws -> User {
        let stats = userStatsFromResult(result.stats)

        var avatar: URL? = nil
        if let avatarRaw = result.avatar, let avatarURL = URL(string: avatarRaw) {
            avatar = avatarURL
        }

        return User(id: result.id,
                nickname: result.nickname,
                avatar: avatar,
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

    // swiftlint:disable:next discouraged_optional_collection
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
