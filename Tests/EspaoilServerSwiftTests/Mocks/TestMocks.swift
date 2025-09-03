import Testing
@testable import EspaoilServerSwift

// MARK: - Mock GasStationPersister
final class MockGasStationPersister: GasStationPersister {
    var replaceCalledWith: [GasStation] = []
    var queryNearGasStationsCalledWith: (coordinates: MaximumCoordinates, gasType: String)?
    var queryNearGasStationsResult: [GasStation] = []
    var shouldThrowError = false
    var errorToThrow: any Error = TestError.mockError
    
    func replace(gasStations: [GasStation]) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        replaceCalledWith = gasStations
    }
    
    func queryNearGasStations(coordinates: MaximumCoordinates, gasType: String) async throws -> [GasStation] {
        if shouldThrowError {
            throw errorToThrow
        }
        queryNearGasStationsCalledWith = (coordinates, gasType)
        return queryNearGasStationsResult
    }
}

// MARK: - Mock GasStationRetriever
final class MockGasStationRetriever: GasStationRetriever {
    var retrieveResult: [GasStation] = []
    var shouldThrowError = false
    var errorToThrow: any Error = TestError.mockError
    var retrieveCallCount = 0
    
    func retrieve() async throws -> [GasStation] {
        retrieveCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        return retrieveResult
    }
}

// MARK: - Test Error
enum TestError: Error {
    case mockError
    case networkError
    case databaseError
}

// MARK: - Test Data Factory
struct TestDataFactory {
    static func createCoordinates() throws -> Coordinates {
        return try Coordinates(latitude: 40.4168, longitude: -3.7038)
    }
    
    static func createLocation() throws -> Location {
        return Location(
            postalCode: "28001",
            address: "Calle Mayor 1",
            time: "24H",
            coordinates: try createCoordinates(),
            municipality: "Madrid",
            province: "Madrid",
            locality: "Madrid"
        )
    }
    
    static func createGasStation(name: String = "Test Station", prices: [String: Double] = ["GASOLINA_95_E5": 1.45]) throws -> GasStation {
        return GasStation(
            name: name,
            location: try createLocation(),
            prices: prices
        )
    }
    
    static func createMaximumCoordinates() -> MaximumCoordinates {
        return MaximumCoordinates(
            maximumSouthCoordinate: 40.0,
            maximumNorthCoordinate: 41.0,
            maximumWestCoordinate: -4.0,
            maximumEastCoordinate: -3.0
        )
    }
}
