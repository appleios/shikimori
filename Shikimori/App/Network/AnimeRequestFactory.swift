//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct AnimeResult: Codable {

    let id: Int
    let name: String
    let russian: String?

    struct AnimeImageResult: Codable {
        let original: String
        let preview: String
        let x96: String
        let x48: String
    }

    let image: AnimeImageResult
    let url: String
    let kind: String
    let status: String?
    let nextEpisodeAt: Int?

}


class AnimeRequestFactory: EndpointRequestFactory {

    func getAnime(byID animeID: Int, session: Session) -> HttpRequest<Anime> {

        let url = urlBuilder.url(withPath: "/api/animes/\(animeID)")
        let request: URLRequest = requestFactory.get(url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: AnimeRequestResultMapper(baseURL: urlBuilder.url(withPath: "")!), // TODO pass urlBuilder?
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}


class AnimeRequestResultMapper: DefaultNetworkRequestResultMapper<AnimeResult, Anime> {

    init(baseURL: URL) {
        super.init(converter: ClosureSalToDomainConverter({ (result: AnimeResult) in

            let nextEpisodeAt: Date? = result.nextEpisodeAt != nil ?
                    Date(timeIntervalSince1970: TimeInterval(exactly: result.nextEpisodeAt!)!) : nil

            let status: UserRates.Status? = result.status != nil
                    ? UserRates.Status(rawValue: result.status!)! : nil

            return Anime(id: result.id,
                    name: result.name,
                    russian: result.russian,
                    originalImageURL: URL(string: result.image.original, relativeTo: baseURL)!,
                    previewImageURL: URL(string: result.image.preview, relativeTo: baseURL)!,
                    url: URL(string: result.url, relativeTo: baseURL)!,
                    kind: Anime.Kind(rawValue: result.kind)!,
                    status: status,
                    nextEpisodeAt: nextEpisodeAt)
        }))
    }

}
