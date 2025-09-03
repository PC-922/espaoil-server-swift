import Testing
@testable import EspaoilServerSwift

@Suite("Retrieve Near Gas Station Tests")
struct RetrieveNearGasStationTests {
    @Test("should return gas stations from repository")
    func testRetrieveNearGasStationSuccess() async throws {
        // Given
        let mockPersister = MockGasStationPersister()
        let expectedGasStations = [
            try TestDataFactory.createGasStation(name: "Station 1", prices: ["GASOLINA_95_E5": 1.45]),
            try TestDataFactory.createGasStation(name: "Station 2", prices: ["GASOLINA_95_E5": 1.50])
        ]
        mockPersister.queryNearGasStationsResult = expectedGasStations

        let useCase = RetrieveNearGasStation(gasStationRepository: mockPersister)
        let coordinates = try TestDataFactory.createCoordinates()

        // When
        let result = try await useCase.execute(
            coordinates: coordinates,
            maximumDistanceInMeters: 5000.0,
            gasType: "GASOLINA_95_E5"
        )

        // Then
        #expect(result.count == 2)
        #expect(result[0].name == "Station 1")
        #expect(result[1].name == "Station 2")
        #expect(mockPersister.queryNearGasStationsCalledWith?.gasType == "GASOLINA_95_E5")
    }

    @Test("should pass correct maximum coordinates to repository")
func testRetrieveNearGasStationPassesCorrectCoordinates() async throws {
    // Given
    let mockPersister = MockGasStationPersister()
    mockPersister.queryNearGasStationsResult = []
    
    let useCase = RetrieveNearGasStation(gasStationRepository: mockPersister)
    let coordinates = try Coordinates(latitude: 40.4168, longitude: -3.7038)
    let distance = 5000.0
    
    // When
    _ = try await useCase.execute(
        coordinates: coordinates,
        maximumDistanceInMeters: distance,
        gasType: "GASOLINA_95_E5"
    )
    
    // Then
    let calledCoordinates = mockPersister.queryNearGasStationsCalledWith?.coordinates
    #expect(calledCoordinates != nil)
    
    // Verificar que las coordenadas máximas se calcularon correctamente
    let expectedMaxCoordinates = coordinates.calculateMaximumCoordinates(maximumDistanceInMeters: distance)
    #expect(abs(calledCoordinates!.maximumSouthCoordinate - expectedMaxCoordinates.maximumSouthCoordinate) < 0.001)
    #expect(abs(calledCoordinates!.maximumNorthCoordinate - expectedMaxCoordinates.maximumNorthCoordinate) < 0.001)
    #expect(abs(calledCoordinates!.maximumWestCoordinate - expectedMaxCoordinates.maximumWestCoordinate) < 0.001)
    #expect(abs(calledCoordinates!.maximumEastCoordinate - expectedMaxCoordinates.maximumEastCoordinate) < 0.001)
}

@Test("should throw error when repository fails")
func testRetrieveNearGasStationThrowsError() async throws {
    // Given
    let mockPersister = MockGasStationPersister()
    mockPersister.shouldThrowError = true
    mockPersister.errorToThrow = TestError.databaseError
    
    let useCase = RetrieveNearGasStation(gasStationRepository: mockPersister)
    let coordinates = try TestDataFactory.createCoordinates()

    // When & Then
    await #expect(throws: TestError.databaseError) {
        try await useCase.execute(
            coordinates: coordinates,
            maximumDistanceInMeters: 5000.0,
            gasType: "GASOLINA_95_E5"
        )
    }
}

@Test("should handle empty result from repository")
func testRetrieveNearGasStationEmptyResult() async throws {
    // Given
    let mockPersister = MockGasStationPersister()
    mockPersister.queryNearGasStationsResult = []
    
    let useCase = RetrieveNearGasStation(gasStationRepository: mockPersister)
    let coordinates = try TestDataFactory.createCoordinates()

    // When
    let result = try await useCase.execute(
        coordinates: coordinates,
        maximumDistanceInMeters: 5000.0,
        gasType: "GASOLINA_95_E5"
    )
    
    // Then
    #expect(result.isEmpty)
}

@Test("should work with different gas types")
func testRetrieveNearGasStationDifferentGasTypes() async throws {
    // Given
    let mockPersister = MockGasStationPersister()
    let gasStation = try TestDataFactory.createGasStation(prices: [
        "GASOLINA_95_E5": 1.45,
        "GASOLINA_98_E5": 1.55,
        "GASOLEO_A": 1.35
    ])
    mockPersister.queryNearGasStationsResult = [gasStation]
    
    let useCase = RetrieveNearGasStation(gasStationRepository: mockPersister)
    let coordinates = try TestDataFactory.createCoordinates()
    
    // When
    _ = try await useCase.execute(
        coordinates: coordinates,
        maximumDistanceInMeters: 5000.0,
        gasType: "GASOLEO_A"
    )
    
    // Then
    #expect(mockPersister.queryNearGasStationsCalledWith?.gasType == "GASOLEO_A")
}
}