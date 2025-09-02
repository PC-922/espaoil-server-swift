protocol GasStationRetriever {
    func retrieve() async throws -> [GasStation]
}