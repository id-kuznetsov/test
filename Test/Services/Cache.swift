//
//  Cache.swift
//  Test
//
//  Created by Ilya Kuznetsov on 26.02.2025.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrappedCache = NSCache<WrappedKey, Entry>()
    private let entryLifetime: TimeInterval
    private let dateProvider: () -> Date

    init(entryLifetime: TimeInterval = 600, dateProvider: @escaping () -> Date = Date.init) {
        self.entryLifetime = entryLifetime
        self.dateProvider = dateProvider
    }

    func insert(_ value: Value, forKey key: Key) {
        let expirationDate = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(value: value, expirationDate: expirationDate)
        wrappedCache.setObject(entry, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrappedCache.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    func removeValue(forKey key: Key) {
        wrappedCache.removeObject(forKey: WrappedKey(key))
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? WrappedKey else { return false }
            return key == other.key
        }
    }

    final class Entry: NSObject {
        let value: Value
        let expirationDate: Date

        init(value: Value, expirationDate: Date) {
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}
