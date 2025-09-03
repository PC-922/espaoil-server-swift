import Vapor

struct NearGasStationController: RouteCollection {

    private let gasStationPersister: any GasStationPersister
    private let gasStationRetriever: any GasStationRetriever

    init(gasStationPersister: any GasStationPersister, gasStationRetriever: any GasStationRetriever)
    {
        self.gasStationPersister = gasStationPersister
        self.gasStationRetriever = gasStationRetriever
    }

    func boot(routes: any RoutesBuilder) throws {
        let gasStationsRoute = routes.grouped("gas-stations")
        let updateGasStationsRoute = gasStationsRoute.grouped("update")
        let nearGasStationsRoute = gasStationsRoute.grouped("near")
        updateGasStationsRoute.get(use: updateGasStations)
        nearGasStationsRoute.get(use: getNearGasStations)
    }

    func getNearGasStations(req: Request) async throws -> [NearGasStationsDTO] {
        let latitude = try req.query.get(Double.self, at: "lat")
        let longitude = try req.query.get(Double.self, at: "lon")
        let distance = try req.query.get(Double.self, at: "distance")
        let gasType = try normalizeGasType(req.query.get(String.self, at: "gasType"))
        req.logger.info(
            "Retrieving near gas stations for lat: \(latitude), long: \(longitude), distance: \(distance), gasType: \(gasType)"
        )
        do {
            let nearGasStations = try await RetrieveNearGasStation(
                gasStationRepository: gasStationPersister
            )
            .execute(
                coordinates: Coordinates(
                    latitude: latitude,
                    longitude: longitude
                ),
                maximumDistanceInMeters: distance,
                gasType: gasType
            )
            .map { NearGasStationsDTO.fromGasStation($0, gasType: gasType) }
            req.logger.info("Retrieved \(nearGasStations.count) near gas stations")
            return nearGasStations
        } catch {
            req.logger.error("Failed to retrieve near gas stations: \(error)")
            throw error
        }
    }

    func updateGasStations(req: Request) async throws -> HTTPStatus {
        try await UpdateGasStations(
            gasStationRetriever: gasStationRetriever,
            gasStationPersister: gasStationPersister
        ).execute()
        return .ok
    }
}

extension NearGasStationController {
    fileprivate func normalizeGasType(_ gasType: String) -> String {
        return switch gasType.uppercased() {
        case "GASOLINA_95_E5": "GASOLINA_95_E5"
        case "GASOLINA_95_E5_PREMIUM": "GASOLINA_95_E5_PREMIUM"
        case "GASOLINA_95_E10": "GASOLINA_95_E10"
        case "GASOLINA_98_E5": "GASOLINA_98_E5"
        case "GASOLINA_98_E10": "GASOLINA_98_E10"
        case "GASOIL_A": "GASOIL_A"
        case "GASOIL_B": "GASOIL_B"
        case "GASOIL_PREMIUM": "GASOIL_PREMIUM"
        default: gasType
        }
    }
}
