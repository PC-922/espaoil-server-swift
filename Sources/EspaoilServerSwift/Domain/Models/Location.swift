struct Location {
    let postalCode: String
    let address: String
    let time: String
    let coordinates: Coordinates
    let municipality: String
    let province: String
    let locality: String

    var latitude: Double {
        return coordinates.latitude
    }

    var longitude: Double {
        return coordinates.longitude
    }
}
