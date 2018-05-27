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
    let nextEpisodeAt: Date?

}

class AnimeRequestFactory: EndpointRequestFactory {

    func getAnime(byID animeID: Int, session: Session) -> HttpRequest<Anime> {

        // swiftlint:disable:next force_unwrapping
        let url = urlBuilder.url(withPath: "/api/animes/\(animeID)")!
        let request: URLRequest = requestFactory.get(url, accessToken: session.token.accessToken)

        // swiftlint:disable:next force_unwrapping
        let baseURL = urlBuilder.url(withPath: "")!

        return HttpRequest(urlRequest: request,
                mapper: AnimeRequestResultMapper(baseURL: baseURL),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}

class AnimeRequestResultMapper: AbstractNetworkRequestResultMapper<AnimeResult, Anime> {

    static func dateFormatterForISO8601() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }

    static var defaultJSONDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = dateFormatterForISO8601()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    override func decode(_ data: Data) throws -> AnimeResult {
        return try AnimeRequestResultMapper.defaultJSONDecoder.decode(AnimeResult.self, from: data)
    }

    override func convert(_ result: AnimeResult) throws -> Anime {
        guard let originalImageURL = URL(string: result.image.original, relativeTo: baseURL),
              let previewImageURL = URL(string: result.image.preview, relativeTo: baseURL),
              let animeURL = URL(string: result.url, relativeTo: baseURL),
              let animeKind = Anime.Kind(rawValue: result.kind)
        else {
            fatalError("Corrupted data") // TODO transform int .corruptedData exception
        }

        return Anime(id: result.id,
                name: result.name,
                russian: result.russian,
                originalImageURL: originalImageURL,
                previewImageURL: previewImageURL,
                url: animeURL,
                kind: animeKind,
                status: result.status,
                nextEpisodeAt: result.nextEpisodeAt)
    }
}
