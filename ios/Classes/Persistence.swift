import Foundation
import CoreLocation
import SQLite

class Persistence {
    internal let connection: Connection
    static let traces = Table("traces")
    static let id = Expression<Int64>("id")
    static let latitude = Expression<Double>("latitude")
    static let longitude = Expression<Double>("longitude")
    static let altitude = Expression<Double>("altitude")
    static let speed = Expression<Double>("speed")
    static let accuracy = Expression<Double>("accuracy")
    static let readCount = Expression<Int>("read_count")
    static let time = Expression<Double>("time")

    static let course = Expression<Double>("course")
    static let verticalAccuracy = Expression<Double>("verticalAccuracy")
    
    init(_ db: String) throws {
        do {
            self.connection = try Connection(db)
        } catch let error as NSError {
            throw error
        }
    }
    
    static func getSqliteDbFileName() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1].appendingPathComponent("plugins.gjg.io_background_location_updates.sqlite.db").absoluteString
    }
    
    @discardableResult
    func createSchema() -> Bool {
        let result = try? connection.run(Persistence.traces.create(ifNotExists: true) { t in
            t.column(Persistence.id, primaryKey: .autoincrement)
            t.column(Persistence.latitude)
            t.column(Persistence.longitude)
            t.column(Persistence.altitude)
            t.column(Persistence.speed)
            t.column(Persistence.accuracy)
            t.column(Persistence.readCount)
            t.column(Persistence.time)
            t.column(Persistence.course)
            t.column(Persistence.verticalAccuracy)
        })
        return result != nil
    }
    
    @discardableResult
    func persist(_ loc: CLLocation) -> Int64? {
        return try? connection.run(Persistence.traces.insert(
            Persistence.latitude <- loc.coordinate.latitude.datatypeValue,
            Persistence.longitude <- loc.coordinate.longitude.datatypeValue,
            Persistence.altitude <- loc.altitude.datatypeValue,
            Persistence.speed <- loc.speed.datatypeValue,
            Persistence.accuracy <- loc.horizontalAccuracy,
            Persistence.verticalAccuracy <- loc.verticalAccuracy,
            Persistence.time <- loc.timestamp.timeIntervalSince1970 * 1000,
            Persistence.readCount <- 0,
            Persistence.course <- loc.course
        ))
    }
    
    func getAll() -> Array<Dictionary<String, Double>>? {
        return fetchAndTransform(Persistence.traces)
    }
    
    func getAllCount() -> Int? {
        return try? connection.scalar(Persistence.traces.count)
    }
    
    func getAllUnreadCount() -> Int? {
        return try? connection.scalar(Persistence.traces.filter(Persistence.readCount == 0).count)
    }
    
    func getUnread() -> Array<Dictionary<String, Double>>? {
        return fetchAndTransform(Persistence.traces.where(Persistence.readCount < 1))
    }
    
    func fetchAndTransform(_ query: QueryType) -> Array<Dictionary<String, Double>>? {
        var traces: Array<Dictionary<String, Double>> = []
        do {
            for row in try connection.prepare(query) {
                traces.append([
                    "latitude": try row.get(Persistence.latitude),
                    "longitude": try row.get(Persistence.longitude),
                    "altitude": try row.get(Persistence.altitude),
                    "speed": try row.get(Persistence.speed),
                    "accuracy": try row.get(Persistence.accuracy),
                    "verticalAccuracy": try row.get(Persistence.verticalAccuracy),
                    "readCount": Double(try row.get(Persistence.readCount)),
                    "time": try row.get(Persistence.time),
                    "id": Double(try row.get(Persistence.id)),
                    "course": try row.get(Persistence.course)
                ])
            }
        } catch let error as NSError {
            NSLog("Error fetching from Trace DB: %@", error)
            return nil
        }
        return traces
    }
    
    @discardableResult
    func markAsRead(_ ids: Array<Int>) -> Int? {
        let i64Ids = ids.map { (i: Int) -> Int64 in
            Int64(i)
        }
       let update = Persistence.traces.filter(i64Ids.contains(Persistence.id))
            .update(Persistence.readCount += 1)
       return try? connection.run(update)
    }
}
