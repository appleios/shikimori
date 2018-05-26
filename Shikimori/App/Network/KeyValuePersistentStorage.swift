//
// Created by Aziz Latipov on 27.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

class KeyValuePersistentStorage<T> where T: Codable {

    static func userDefaultsStorage<T>(withKey key: String) -> UserDefaultsKeyValuePersistentStorage<T> {
        return UserDefaultsKeyValuePersistentStorage<T>(key: key)
    }

    static func archiverStorage<T>(withKey key: String) -> ArchiverKeyValuePersistentStorage<T> {
        return ArchiverKeyValuePersistentStorage<T>(key: key)
    }

    let key: String

    init(key: String) {
        self.key = key
    }

    var value: T? {
        set {
            if let value = newValue {
                self.storeValue(value: value, forKey: key)
            } else {
                do {
                    try self.removeValue(forKey: key)
                } catch {
                }
            }
        }
        get {
            return self.loadValue(forKey: key)
        }
    }

    internal func storeValue(value: T, forKey key: String) {
    }

    internal func loadValue(forKey key: String) -> T? {
        return nil
    }

    internal func removeValue(forKey key: String) throws {
    }
}

class UserDefaultsKeyValuePersistentStorage<T>: KeyValuePersistentStorage<T> where T: Codable {

    override func storeValue(value: T, forKey key: String) {
        do {
            let data = try PropertyListEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        } catch {
        }
    }

    override func loadValue(forKey key: String) -> T? {
        do {
            if let data = UserDefaults.standard.value(forKey: key) as? Data {
                return try PropertyListDecoder().decode(T.self, from: data)
            }
        } catch {
        }
        return nil
    }

    override func removeValue(forKey key: String) throws {
        UserDefaults.standard.removeObject(forKey: key)
    }

}

class ArchiverKeyValuePersistentStorage<T>: KeyValuePersistentStorage<T> where T: Codable {

    override func storeValue(value: T, forKey key: String) {
        do {
            let data = try PropertyListEncoder().encode(value)
            NSKeyedArchiver.archiveRootObject(data, toFile: self.filePathForKey(key))
        } catch {
        }
    }

    override func loadValue(forKey key: String) -> T? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: self.filePathForKey(key)) as? Data else {
            return nil
        }

        do {
            return try PropertyListDecoder().decode(T.self, from: data)
        } catch {
        }
        return nil
    }

    override func removeValue(forKey key: String) throws {
        let path: String = self.filePathForKey(key)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
    }

    private func filePathForKey(_ key: String) -> String {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key).path
    }

}
