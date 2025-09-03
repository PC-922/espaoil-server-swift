import Fluent

final class CoordinatesPersistanceDTO: Model, @unchecked Sendable {
    static let schema = "coordinates"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    init() { }

    init(id: UUID? = nil, latitude: Double, longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}