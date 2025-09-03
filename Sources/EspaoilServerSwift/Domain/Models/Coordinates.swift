import Foundation

struct Coordinates {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) throws {
        guard Self.isValidLatitude(latitude) else {
            throw CoordinatesError.invalidLatitude(latitude)
        }
        
        guard Self.isValidLongitude(longitude) else {
            throw CoordinatesError.invalidLongitude(longitude)
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }

    private static func isValidLatitude(_ latitude: Double) -> Bool {
        return latitude >= -90.0 && latitude <= 90.0
    }
    
    private static func isValidLongitude(_ longitude: Double) -> Bool {
        return longitude >= -180.0 && longitude <= 180.0
    }

    func calculateMaximumCoordinates(maximumDistanceInMeters: Double) -> MaximumCoordinates {
        let earth = 6378.137
        let m = (1 / ((2 * Double.pi / 360) * earth)) / 1000
        let maximumNorthCoordinate = latitude + (maximumDistanceInMeters * m)
        let maximumSouthCoordinate = latitude + (-maximumDistanceInMeters * m)
        let maximumEastCoordinate = longitude + (maximumDistanceInMeters * m) / cos(latitude * (Double.pi / 180))
        let maximumWestCoordinate = longitude + (-maximumDistanceInMeters * m) / cos(latitude * (Double.pi / 180))
        return MaximumCoordinates(
            maximumSouthCoordinate: maximumSouthCoordinate,
            maximumNorthCoordinate: maximumNorthCoordinate,
            maximumWestCoordinate: maximumWestCoordinate,
            maximumEastCoordinate: maximumEastCoordinate
        )
    }
}

enum CoordinatesError: Error, LocalizedError {
    case invalidLatitude(Double)
    case invalidLongitude(Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidLatitude(let value):
            return "Invalid latitude: \(value). Must be between -90.0 and 90.0 degrees."
        case .invalidLongitude(let value):
            return "Invalid longitude: \(value). Must be between -180.0 and 180.0 degrees."
        }
    }
}
