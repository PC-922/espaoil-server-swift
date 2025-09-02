import Fluent

final class GasStationPersistanceDTO: Model, @unchecked Sendable {
    static let schema = "gas_stations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "location_id")
    var location: LocationPersistanceDTO

    @Field(key: "prices")
    var prices: [String: Double]

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        locationID: LocationPersistanceDTO.IDValue,
        prices: [String: Double]
    ) {
        self.id = id
        self.name = name
        self.$location.id = locationID
        self.prices = prices
    }

    func toDomain() -> GasStation {
        return GasStation(
            name: name,
            location: Location(
                postalCode: location.postalCode,
                address: location.address,
                time: location.time,
                coordinates: Coordinates(
                    latitude: location.coordinates.latitude,
                    longitude: location.coordinates.longitude
                ),
                municipality: location.municipality,
                province: location.province,
                locality: location.locality
            ),
            prices: prices
        )
    }
}
