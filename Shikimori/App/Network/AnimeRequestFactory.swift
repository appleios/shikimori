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

        let url = urlBuilder.url(withPath: "/api/animes/\(animeID)")
        let request: URLRequest = requestFactory.get(url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: AnimeRequestResultMapper(baseURL: urlBuilder.url(withPath: "")!), // TODO pass urlBuilder?
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}

class AnimeRequestResultMapper: DefaultNetworkRequestResultMapper<AnimeResult, Anime> {

    static func dateFormatterForISO8601() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }

    // TODO fix ugly duplication
    class JsonResultDecoder2: NetworkDataDecoder<AnimeResult> {

        // TODO get JSONDecoder from single entry among all points
        static var defaultJSONDecoder: JSONDecoder {
            let decoder = JSONDecoder()
            let dateFormatter = dateFormatterForISO8601()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }

        var jsonDecoder: JSONDecoder

        init(jsonDecoder: JSONDecoder = defaultJSONDecoder) {
            self.jsonDecoder = jsonDecoder
        }

        override func decode(_ data: Data) throws -> AnimeResult {
            return try jsonDecoder.decode(AnimeResult.self, from: data)
        }

    }

    init(baseURL: URL) {

        super.init(converter: ClosureSalToDomainConverter({ (result: AnimeResult) in
            return Anime(id: result.id,
                    name: result.name,
                    russian: result.russian,
                    originalImageURL: URL(string: result.image.original, relativeTo: baseURL)!,
                    previewImageURL: URL(string: result.image.preview, relativeTo: baseURL)!,
                    url: URL(string: result.url, relativeTo: baseURL)!,
                    kind: Anime.Kind(rawValue: result.kind)!,
                    status: result.status,
                    nextEpisodeAt: result.nextEpisodeAt)

        }), decoder: JsonResultDecoder2())
    }

}
