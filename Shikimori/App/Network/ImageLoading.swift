//
// Created by Aziz Latipov on 28.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit

protocol ImageLoading {

    var imageP: Promise<UIImage> { get }
    var placeholder: UIImage? { get }

}

extension ImageLoading {

    var image: UIImage? {
        switch imageP.state {
        case .fulfilled(let value):
            return value
        default:
            return self.placeholder
        }
    }

}

protocol ImageCache {

    func image(withFilename filename: String) -> UIImage?
    func saveImage(locatedAtURL url: URL, withFilename filename: String)
}

class ImageLoadingHelper {

    static func getImage(atURL url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

}

class PersistentImageCache: ImageCache {

    static var defaultRootDirectoryURL: URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: path).appendingPathComponent(".images", isDirectory: true)
    }

    private let imagesDirectoryURL: URL
    private let fileManager: FileManager

    init(imagesDirectoryURL: URL = defaultRootDirectoryURL, fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        self.imagesDirectoryURL = imagesDirectoryURL
    }

    func image(withFilename filename: String) -> UIImage? {
        return ImageLoadingHelper.getImage(atURL: targetURL(forFilename: filename))
    }

    func saveImage(locatedAtURL url: URL, withFilename filename: String) {
        do {
            try saveOnDiskImage(locatedAtURL: url, targetURL: targetURL(forFilename: filename))
        } catch {
            print("unexpected error while saving on dis: \(error)")
        }
    }

    private func targetURL(forFilename filename: String) -> URL {
        return imagesDirectoryURL.appendingPathComponent(filename)
    }

    private func saveOnDiskImage(locatedAtURL url: URL, targetURL: URL) throws {
        try createImagesDirectoryIfNeeded()

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: targetURL.path, isDirectory: &isDirectory) {
            try fileManager.removeItem(at: targetURL)
        }
        try fileManager.copyItem(at: url, to: targetURL)
    }

    private func createImagesDirectoryIfNeeded() throws {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: imagesDirectoryURL.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                try fileManager.removeItem(at: imagesDirectoryURL)
                try fileManager.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: false)
            }
        } else {
            try fileManager.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: false)
        }
    }

}

class ImageDownloadOperation: ImageLoading {

    var imageP: Promise<UIImage>
    var placeholder: UIImage?

    private var sourceURL: URL
    private var filename: String
    private let urlSession: URLSession
    private let imageCache: ImageCache

    init(sourceURL: URL,
         filename: String,
         placeholder: UIImage? = nil,
         urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default),
         imageCache: ImageCache = PersistentImageCache()) {
        self.sourceURL = sourceURL
        self.filename = filename
        self.placeholder = placeholder
        self.urlSession = urlSession
        self.imageCache = imageCache
        if let image = imageCache.image(withFilename: filename) {
            self.imageP = Promise(withValue: image)
        } else {
            self.imageP = Promise<UIImage>()
        }
    }

    private var task: URLSessionDownloadTask?

    func load() {
        let imageP = self.imageP
        let completionHandler = { [weak self, imageP] (url: URL?, response: URLResponse?, error: Error?) -> Void in
            guard let sSelf = self else {
                imageP.cancel()
                return
            }

            if let response = response as? HTTPURLResponse, let url = url {
                if response.statusCode == 200 {
                    sSelf.handleSuccess(response: response, url: url)
                } else {
                    imageP.reject(HTTPError(statusCode: response.statusCode))
                }
            } else if let error = error {
                imageP.reject(error)
            } else {
                imageP.cancel()
                fatalError("unexpected behaviour: either it should be OK and correct data, either should be error")
            }
        }

        let task: URLSessionDownloadTask =
                self.urlSession.downloadTask(with: self.sourceURL, completionHandler: completionHandler)

        task.resume()

        self.task = task
    }

    private func handleSuccess(response: HTTPURLResponse, url: URL) {
        guard let image = ImageLoadingHelper.getImage(atURL: url) else {
            fatalError("unexpected case") // TODO correctly handle
        }

        imageCache.saveImage(locatedAtURL: url, withFilename: filename)
        imageP.fulfill(image)
    }

}
