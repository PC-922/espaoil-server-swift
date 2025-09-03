import Testing

@testable import EspaoilServerSwift

@Suite("Update Gas Stations Tests")
struct UpdateGasStationsTests {
    @Test("should retrieve and persist gas stations successfully")
    func testUpdateGasStationsSuccess() async throws {
        // Given
        let mockRetriever = MockGasStationRetriever()
        let mockPersister = MockGasStationPersister()

        let expectedGasStations = [
            try TestDataFactory.createGasStation(name: "Station 1"),
            try TestDataFactory.createGasStation(name: "Station 2"),
            try TestDataFactory.createGasStation(name: "Station 3"),
        ]
        mockRetriever.retrieveResult = expectedGasStations

        let useCase = UpdateGasStations(
            gasStationRetriever: mockRetriever,
            gasStationPersister: mockPersister
        )

        // When
        try await useCase.execute()

        // Then
        #expect(mockRetriever.retrieveCallCount == 1)
        #expect(mockPersister.replaceCalledWith.count == 3)
        #expect(mockPersister.replaceCalledWith[0].name == "Station 1")
        #expect(mockPersister.replaceCalledWith[1].name == "Station 2")
        #expect(mockPersister.replaceCalledWith[2].name == "Station 3")
    }

    @Test("should not persist when retriever returns empty list")
    func testUpdateGasStationsWithEmptyResult() async throws {
        // Given
        let mockRetriever = MockGasStationRetriever()
        let mockPersister = MockGasStationPersister()

        mockRetriever.retrieveResult = []  // Empty result

        let useCase = UpdateGasStations(
            gasStationRetriever: mockRetriever,
            gasStationPersister: mockPersister
        )

        // When
        try await useCase.execute()

        // Then
        #expect(mockRetriever.retrieveCallCount == 1)
        #expect(mockPersister.replaceCalledWith.isEmpty)  // Should not be called with empty list
    }

    @Test("should throw error when retriever fails")
    func testUpdateGasStationsRetrieverError() async throws {
        // Given
        let mockRetriever = MockGasStationRetriever()
        let mockPersister = MockGasStationPersister()

        mockRetriever.shouldThrowError = true
        mockRetriever.errorToThrow = TestError.networkError

        let useCase = UpdateGasStations(
            gasStationRetriever: mockRetriever,
            gasStationPersister: mockPersister
        )

        // When & Then
        await #expect(throws: TestError.networkError) {
            try await useCase.execute()
        }

        // Verify persister was not called
        #expect(mockPersister.replaceCalledWith.isEmpty)
    }

    @Test("should throw error when persister fails")
    func testUpdateGasStationsPersisterError() async throws {
        // Given
        let mockRetriever = MockGasStationRetriever()
        let mockPersister = MockGasStationPersister()

        let gasStations = [try TestDataFactory.createGasStation()]
        mockRetriever.retrieveResult = gasStations
        mockPersister.shouldThrowError = true
        mockPersister.errorToThrow = TestError.databaseError

        let useCase = UpdateGasStations(
            gasStationRetriever: mockRetriever,
            gasStationPersister: mockPersister
        )

        // When & Then
        await #expect(throws: TestError.databaseError) {
            try await useCase.execute()
        }

        // Verify retriever was called but persister failed
        #expect(mockRetriever.retrieveCallCount == 1)
    }

    @Test("should handle single gas station correctly")
    func testUpdateGasStationsSingleStation() async throws {
        // Given
        let mockRetriever = MockGasStationRetriever()
        let mockPersister = MockGasStationPersister()

        let singleStation = try TestDataFactory.createGasStation(
            name: "Single Station",
            prices: ["GASOLINA_95_E5": 1.45, "GASOLEO_A": 1.35]
        )
        mockRetriever.retrieveResult = [singleStation]

        let useCase = UpdateGasStations(
            gasStationRetriever: mockRetriever,
            gasStationPersister: mockPersister
        )

        // When
        try await useCase.execute()

        // Then
        #expect(mockRetriever.retrieveCallCount == 1)
        #expect(mockPersister.replaceCalledWith.count == 1)
        #expect(mockPersister.replaceCalledWith[0].name == "Single Station")
        #expect(mockPersister.replaceCalledWith[0].prices["GASOLINA_95_E5"] == 1.45)
        #expect(mockPersister.replaceCalledWith[0].prices["GASOLEO_A"] == 1.35)
    }

    @Test("should preserve gas station data integrity")
    func testUpdateGasStationsDataIntegrity() async throws {
        // Given
        let mockRetriever = MockGasStationRetriever()
        let mockPersister = MockGasStationPersister()

        let originalStation = try TestDataFactory.createGasStation(
            name: "Test Station",
            prices: [
                "GASOLINA_95_E5": 1.45,
                "GASOLINA_98_E5": 1.55,
                "GASOLEO_A": 1.35,
            ]
        )
        mockRetriever.retrieveResult = [originalStation]

        let useCase = UpdateGasStations(
            gasStationRetriever: mockRetriever,
            gasStationPersister: mockPersister
        )

        // When
        try await useCase.execute()

        // Then
        let persistedStation = mockPersister.replaceCalledWith[0]
        #expect(persistedStation.name == originalStation.name)
        #expect(persistedStation.location.postalCode == originalStation.location.postalCode)
        #expect(persistedStation.location.address == originalStation.location.address)
        #expect(
            persistedStation.location.coordinates.latitude
                == originalStation.location.coordinates.latitude)
        #expect(
            persistedStation.location.coordinates.longitude
                == originalStation.location.coordinates.longitude)
        #expect(persistedStation.prices.count == 3)
        #expect(persistedStation.prices["GASOLINA_95_E5"] == 1.45)
        #expect(persistedStation.prices["GASOLINA_98_E5"] == 1.55)
        #expect(persistedStation.prices["GASOLEO_A"] == 1.35)
    }
}
