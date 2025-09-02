protocol GasStationPersister {
    func replace(gasStations: [GasStation]) async throws
    func queryNearGasStations(coordinates: MaximumCoordinates, gasType: String) async throws -> [GasStation]
}