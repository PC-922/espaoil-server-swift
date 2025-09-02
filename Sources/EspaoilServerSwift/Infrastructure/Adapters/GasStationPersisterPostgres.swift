import Fluent

final class GasStationPersisterPostgres: GasStationPersister {

    private let db: any Database

    init(db: any Database) {
        self.db = db
    }

    func replace(gasStations: [GasStation]) async throws {
        try await deleteGasStations()
        try await saveGasStations(gasStations: gasStations)
    }

    func queryNearGasStations(
        coordinates: MaximumCoordinates,
        gasType: String
    ) async throws -> [GasStation] {
        let dtos = try await GasStationPersistanceDTO.query(on: db)
            .with(\.$location) { location in
                location.with(\.$coordinates)
            }
            .join(
                LocationPersistanceDTO.self,
                on: \GasStationPersistanceDTO.$location.$id == \LocationPersistanceDTO.$id
            )
            .join(
                CoordinatesPersistanceDTO.self,
                on: \LocationPersistanceDTO.$coordinates.$id == \CoordinatesPersistanceDTO.$id
            )
            .filter(
                CoordinatesPersistanceDTO.self, \.$latitude >= coordinates.maximumSouthCoordinate
            )
            .filter(
                CoordinatesPersistanceDTO.self, \.$latitude <= coordinates.maximumNorthCoordinate
            )
            .filter(
                CoordinatesPersistanceDTO.self, \.$longitude >= coordinates.maximumWestCoordinate
            )
            .filter(
                CoordinatesPersistanceDTO.self, \.$longitude <= coordinates.maximumEastCoordinate
            )
            .all()

        return Array(
            dtos
                .filter { $0.prices.keys.contains(gasType) }
                .map { $0.toDomain() }
                .sorted { left, right in
                    guard let leftPrice = left.prices[gasType],
                        let rightPrice = right.prices[gasType]
                    else {
                        return false
                    }
                    return leftPrice < rightPrice
                }
                .prefix(30)
        )
    }
}

extension GasStationPersisterPostgres {
    private func deleteGasStations() async throws {
        try await GasStationPersistanceDTO.query(on: db).delete()
    }

    private func saveGasStations(gasStations: [GasStation]) async throws {
        for gasStation in gasStations {
            try await db.transaction { database in
                let coordinates = CoordinatesPersistanceDTO(
                    latitude: gasStation.location.coordinates.latitude,
                    longitude: gasStation.location.coordinates.longitude
                )
                try await coordinates.save(on: database)
                let location = LocationPersistanceDTO(
                    postalCode: gasStation.location.postalCode,
                    address: gasStation.location.address,
                    time: gasStation.location.time,
                    coordinatesID: try coordinates.requireID(),
                    municipality: gasStation.location.municipality,
                    province: gasStation.location.province,
                    locality: gasStation.location.locality
                )
                try await location.save(on: database)
                let gasStationDTO = GasStationPersistanceDTO(
                    name: gasStation.name,
                    locationID: try location.requireID(),
                    prices: gasStation.prices
                )
                try await gasStationDTO.save(on: database)
            }
        }
    }
}
