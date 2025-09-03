final class RetrieveNearGasStation {
    private let gasStationRepository: any GasStationPersister

    init(gasStationRepository: any GasStationPersister) {
        self.gasStationRepository = gasStationRepository
    }

    func execute(coordinates: Coordinates, maximumDistanceInMeters: Double, gasType: String) async throws -> [GasStation] {
        return try await gasStationRepository.queryNearGasStations(
            coordinates: coordinates.calculateMaximumCoordinates(maximumDistanceInMeters: maximumDistanceInMeters),
            gasType: gasType
        )
    }
}