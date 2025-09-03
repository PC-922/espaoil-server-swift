import Testing

@testable import EspaoilServerSwift

@Suite("Domain Validation Tests")
struct DomainValidationTests {  // MARK: - Coordinates Validation Tests
    @Test("Coordinates should validate latitude range")
    func testCoordinatesLatitudeValidation() throws {
        // Valid latitudes should work
        #expect(throws: Never.self) {
            _ = try Coordinates(latitude: 90.0, longitude: 0.0)
        }
        #expect(throws: Never.self) {
            _ = try Coordinates(latitude: -90.0, longitude: 0.0)
        }
        #expect(throws: Never.self) {
            _ = try Coordinates(latitude: 0.0, longitude: 0.0)
        }

        // Invalid latitudes should throw
        #expect(throws: (any Error).self) {
            _ = try Coordinates(latitude: 91.0, longitude: 0.0)
        }
        #expect(throws: (any Error).self) {
            _ = try Coordinates(latitude: -91.0, longitude: 0.0)
        }
    }

    @Test("Coordinates should validate longitude range")
    func testCoordinatesLongitudeValidation() throws {
        // Valid longitudes should work
        #expect(throws: Never.self) {
            _ = try Coordinates(latitude: 0.0, longitude: 180.0)
        }
        #expect(throws: Never.self) {
            _ = try Coordinates(latitude: 0.0, longitude: -180.0)
        }
        #expect(throws: Never.self) {
            _ = try Coordinates(latitude: 0.0, longitude: 0.0)
        }

        // Invalid longitudes should throw
        #expect(throws: (any Error).self) {
            _ = try Coordinates(latitude: 0.0, longitude: 181.0)
        }
        #expect(throws: (any Error).self) {
            _ = try Coordinates(latitude: 0.0, longitude: -181.0)
        }
    }

    @Test("Coordinates should handle edge cases in calculation")
    func testCoordinatesEdgeCases() throws {
        // Test at equator
        let equatorCoords = try Coordinates(latitude: 0.0, longitude: 0.0)
        let maxCoordsEquator = equatorCoords.calculateMaximumCoordinates(
            maximumDistanceInMeters: 1000.0)

        #expect(maxCoordsEquator.maximumNorthCoordinate > 0.0)
        #expect(maxCoordsEquator.maximumSouthCoordinate < 0.0)
        #expect(maxCoordsEquator.maximumEastCoordinate > 0.0)
        #expect(maxCoordsEquator.maximumWestCoordinate < 0.0)

        // Test near poles (high latitude)
        let arcticCoords = try Coordinates(latitude: 85.0, longitude: 0.0)
        let maxCoordsArctic = arcticCoords.calculateMaximumCoordinates(
            maximumDistanceInMeters: 1000.0)

        // At high latitudes, longitude difference should be much larger
        let latDiff = maxCoordsArctic.maximumNorthCoordinate - arcticCoords.latitude
        let lonDiff = maxCoordsArctic.maximumEastCoordinate - arcticCoords.longitude
        #expect(lonDiff > latDiff)  // Longitude difference grows at high latitudes
    }

    // MARK: - Location Tests
    @Test("Location should provide correct computed properties")
    func testLocationComputedProperties() throws {
        // Given
        let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
        let location = Location(
            postalCode: "28001",
            address: "Calle Mayor 1",
            time: "24H",
            coordinates: coordinates,
            municipality: "Madrid",
            province: "Madrid",
            locality: "Centro"
        )

        // Then
        #expect(location.latitude == 40.4168)
        #expect(location.longitude == -3.7038)
        #expect(location.postalCode == "28001")
        #expect(location.address == "Calle Mayor 1")
        #expect(location.time == "24H")
        #expect(location.municipality == "Madrid")
        #expect(location.province == "Madrid")
        #expect(location.locality == "Centro")
    }

    // MARK: - GasStation Business Logic Tests
    @Test("GasStation should provide correct computed properties")
    func testGasStationComputedProperties() throws {
        // Given
        let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
        let location = Location(
            postalCode: "28001",
            address: "Calle Mayor 1",
            time: "06:00-22:00",
            coordinates: coordinates,
            municipality: "Madrid",
            province: "Madrid",
            locality: "Centro"
        )
        let gasStation = GasStation(
            name: "Estación de Servicio Test",
            location: location,
            prices: ["GASOLINA_95_E5": 1.45, "GASOLEO_A": 1.35]
        )

        // Then
        #expect(gasStation.latitude == 40.4168)
        #expect(gasStation.longitude == -3.7038)
        #expect(gasStation.postalCode == "28001")
        #expect(gasStation.address == "Calle Mayor 1")
        #expect(gasStation.time == "06:00-22:00")
        #expect(gasStation.locality == "Centro")
        #expect(gasStation.municipality == "Madrid")
    }

    @Test("GasStation should handle empty prices")
    func testGasStationEmptyPrices() throws {
        // Given
        let location = try TestDataFactory.createLocation()
        let gasStation = GasStation(
            name: "Station Without Prices",
            location: location,
            prices: [:]
        )

        // Then
        #expect(gasStation.prices.isEmpty)
        #expect(gasStation.name == "Station Without Prices")
    }

    @Test("GasStation should handle multiple fuel types")
    func testGasStationMultipleFuelTypes() throws {
        // Given
        let location = try TestDataFactory.createLocation()
        let prices = [
            "GASOLINA_95_E5": 1.45,
            "GASOLINA_98_E5": 1.55,
            "GASOLEO_A": 1.35,
            "GASOLEO_B": 1.25,
            "GASOLEO_PREMIUM": 1.40,
            "BIODIESEL": 1.30,
            "GAS_NATURAL_COMPRIMIDO": 0.95,
        ]
        let gasStation = GasStation(
            name: "Multi-Fuel Station",
            location: location,
            prices: prices
        )

        // Then
        #expect(gasStation.prices.count == 7)
        #expect(gasStation.prices["GASOLINA_95_E5"] == 1.45)
        #expect(gasStation.prices["GAS_NATURAL_COMPRIMIDO"] == 0.95)
    }

    // MARK: - MaximumCoordinates Tests
    @Test("MaximumCoordinates should handle coordinate bounds properly")
    func testMaximumCoordinatesBounds() {
        // Test normal case
        let normalCoords = MaximumCoordinates(
            maximumSouthCoordinate: 40.0,
            maximumNorthCoordinate: 41.0,
            maximumWestCoordinate: -4.0,
            maximumEastCoordinate: -3.0
        )

        #expect(normalCoords.maximumNorthCoordinate > normalCoords.maximumSouthCoordinate)
        #expect(normalCoords.maximumEastCoordinate > normalCoords.maximumWestCoordinate)

        // Test edge case where coordinates cross date line
        let crossDateLineCoords = MaximumCoordinates(
            maximumSouthCoordinate: 35.0,
            maximumNorthCoordinate: 36.0,
            maximumWestCoordinate: 179.0,
            maximumEastCoordinate: -179.0
        )

        #expect(
            crossDateLineCoords.maximumNorthCoordinate > crossDateLineCoords.maximumSouthCoordinate)
        // Note: En este caso west > east es normal al cruzar la línea de fecha
    }

    // MARK: - Domain Validation Tests
    @Test("Domain models should handle special characters in strings")
    func testDomainModelsSpecialCharacters() throws {
        // Given
        let location = Location(
            postalCode: "28001",
            address: "Calle José Ortega y Gasset, 123 - Planta 2ª",
            time: "24H",
            coordinates: try Coordinates(latitude: 40.4168, longitude: -3.7038),
            municipality: "Madrid",
            province: "Comunidad de Madrid",
            locality: "Salamanca - Recoletos"
        )

        let gasStation = GasStation(
            name: "Estación de Servicio Repsol - José Ortega",
            location: location,
            prices: ["GASOLINA_95_E5": 1.459]  // Precio con 3 decimales
        )

        // Then
        #expect(gasStation.address.contains("José Ortega"))
        #expect(gasStation.address.contains("2ª"))
        #expect(gasStation.locality.contains("-"))
        #expect(gasStation.name.contains("Repsol"))
    }

    @Test("Domain models should handle realistic Spanish data")
    func testDomainModelsSpanishData() throws {
        // Given - Datos realistas españoles
        let coordinates = try Coordinates(latitude: 41.3851, longitude: 2.1734)  // Barcelona
        let location = Location(
            postalCode: "08008",
            address: "Avinguda Diagonal, 640",
            time: "06:00-23:00",
            coordinates: coordinates,
            municipality: "Barcelona",
            province: "Barcelona",
            locality: "L'Eixample"
        )

        let prices = [
            "GASOLINA_95_E5": 1.459,
            "GASOLINA_98_E5": 1.579,
            "GASOLEO_A": 1.369,
            "GASOLEO_PREMIUM": 1.429,
        ]

        let gasStation = GasStation(
            name: "CEPSA - Diagonal",
            location: location,
            prices: prices
        )

        // Then
        #expect(gasStation.latitude == 41.3851)
        #expect(gasStation.longitude == 2.1734)
        #expect(gasStation.postalCode == "08008")
        #expect(gasStation.locality == "L'Eixample")
        #expect(gasStation.prices.count == 4)
    }
}
