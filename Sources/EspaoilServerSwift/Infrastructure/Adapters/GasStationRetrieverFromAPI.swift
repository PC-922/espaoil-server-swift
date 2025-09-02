import Vapor

final class GasStationRetrieverFromAPI: GasStationRetriever {

    private let client: any Client
    private let endpointURL: URI = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/"

    init(client: any Client) {
        self.client = client
    }

    func retrieve() async throws -> [GasStation] {
        let response = try await client.get(endpointURL) { req in
            req.headers.add(name: .accept, value: "application/json")
        }
        let gasStationDTOs = try response.content.decode(RetrieverResponseDTO.self)
        let gasStations = gasStationDTOs.prices.compactMap { $0.toDomain() }
        return gasStations
    }
}