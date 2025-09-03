import Testing

@testable import EspaoilServerSwift

@Suite("Domain Models Tests")
struct DomainModelsTests {
    @Test("Coordinates should calculate maximum coordinates correctly")
    func testCoordinatesCalculateMaximumCoordinates() throws {
        // Given
        let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
        let distance = 5000.0  // 5km

        // When
        let maxCoordinates = coordinates.calculateMaximumCoordinates(
            maximumDistanceInMeters: distance)

        // Then
        #expect(maxCoordinates.maximumNorthCoordinate > coordinates.latitude)
        #expect(maxCoordinates.maximumSouthCoordinate < coordinates.latitude)
        #expect(maxCoordinates.maximumEastCoordinate > coordinates.longitude)
        #expect(maxCoordinates.maximumWestCoordinate < coordinates.longitude)

        // Verify the distance is approximately correct (5km ≈ 0.045 degrees)
        let latitudeDifference = maxCoordinates.maximumNorthCoordinate - coordinates.latitude
        let longitudeDifference = maxCoordinates.maximumEastCoordinate - coordinates.longitude

        #expect(latitudeDifference > 0.04 && latitudeDifference < 0.05)
        #expect(longitudeDifference > 0.04 && longitudeDifference < 0.07)  // Longitude varies with latitude
    }

    @Test("Coordinates should handle zero distance")
    func testCoordinatesZeroDistance() throws {
        // Given
        let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
        let distance = 0.0

        // When
        let maxCoordinates = coordinates.calculateMaximumCoordinates(
            maximumDistanceInMeters: distance)

        // Then
        #expect(maxCoordinates.maximumNorthCoordinate == coordinates.latitude)
        #expect(maxCoordinates.maximumSouthCoordinate == coordinates.latitude)
        #expect(maxCoordinates.maximumEastCoordinate == coordinates.longitude)
        #expect(maxCoordinates.maximumWestCoordinate == coordinates.longitude)
    }

    @Test("Coordinates should handle large distances")
    func testCoordinatesLargeDistance() throws {
        // Given
        let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
        let distance = 100000.0  // 100km

        // When
        let maxCoordinates = coordinates.calculateMaximumCoordinates(
            maximumDistanceInMeters: distance)

        // Then
        let latitudeDifference = maxCoordinates.maximumNorthCoordinate - coordinates.latitude
        let longitudeDifference = maxCoordinates.maximumEastCoordinate - coordinates.longitude

        // 100km should be approximately 0.9 degrees latitude
        #expect(latitudeDifference > 0.8 && latitudeDifference < 1.0)
        #expect(longitudeDifference > 0.8)  // Longitude difference will be larger due to cos(latitude)
    }

    @Test("GasStation domain model should be created correctly")
    func testGasStationCreation() throws {
        // Given
        let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
        let location = Location(
            postalCode: "28001",
            address: "Calle Mayor 1",
            time: "24H",
            coordinates: coordinates,
            municipality: "Madrid",
            province: "Madrid",
            locality: "Madrid"
        )
        let prices = ["GASOLINA_95_E5": 1.45, "GASOLEO_A": 1.35]

        // When
        let gasStation = GasStation(
            name: "Test Station",
            location: location,
            prices: prices
        )

        // Then
        #expect(gasStation.name == "Test Station")
        #expect(gasStation.location.postalCode == "28001")
        #expect(gasStation.location.coordinates.latitude == 40.4168)
        #expect(gasStation.location.coordinates.longitude == -3.7038)
        #expect(gasStation.prices["GASOLINA_95_E5"] == 1.45)
        #expect(gasStation.prices["GASOLEO_A"] == 1.35)
    }

    @Test("MaximumCoordinates should be created correctly")
    func testMaximumCoordinatesCreation() {
        // Given & When
        let maxCoords = MaximumCoordinates(
            maximumSouthCoordinate: 40.0,
            maximumNorthCoordinate: 41.0,
            maximumWestCoordinate: -4.0,
            maximumEastCoordinate: -3.0
        )

        // Then
        #expect(maxCoords.maximumSouthCoordinate == 40.0)
        #expect(maxCoords.maximumNorthCoordinate == 41.0)
        #expect(maxCoords.maximumWestCoordinate == -4.0)
        #expect(maxCoords.maximumEastCoordinate == -3.0)

    }

}
