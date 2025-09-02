final class UpdateGasStations {
    private let gasStationRetriever: any GasStationRetriever
    private let gasStationPersister: any GasStationPersister

    init(
        gasStationRetriever: any GasStationRetriever,
        gasStationPersister: any GasStationPersister
    ) {
        self.gasStationRetriever = gasStationRetriever
        self.gasStationPersister = gasStationPersister
    }

    func execute() async throws {
        let gasStations = try await gasStationRetriever.retrieve()
        if gasStations.isEmpty {
            return
        }
        try await gasStationPersister.replace(gasStations: gasStations)
    }
}