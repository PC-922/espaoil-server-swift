import Fluent

final class LocationPersistanceDTO: Model, @unchecked Sendable {
    static let schema = "locations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "postalCode")
    var postalCode: String

    @Field(key: "address")
    var address: String

    @Field(key: "time")
    var time: String

    @Parent(key: "coordinates_id")
    var coordinates: CoordinatesPersistanceDTO

    @Field(key: "municipality")
    var municipality: String

    @Field(key: "province")
    var province: String

    @Field(key: "locality")
    var locality: String

    init() {}

    init(
        id: UUID? = nil,
        postalCode: String,
        address: String,
        time: String,
        coordinatesID: CoordinatesPersistanceDTO.IDValue,
        municipality: String,
        province: String,
        locality: String
    ) {
        self.id = id
        self.postalCode = postalCode
        self.address = address
        self.time = time
        self.$coordinates.id = coordinatesID
        self.municipality = municipality
        self.province = province
        self.locality = locality
    }
}
