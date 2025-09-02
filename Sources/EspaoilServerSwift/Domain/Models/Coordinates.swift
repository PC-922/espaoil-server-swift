import Foundation

struct Coordinates {
    let latitude: Double
    let longitude: Double

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
