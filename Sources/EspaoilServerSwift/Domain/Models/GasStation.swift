struct GasStation {
    let name: String
    let location: Location
    let prices: [String: Double]

    var latitude: Double {
        return location.latitude
    }

    var longitude: Double {
        return location.longitude
    }

    var postalCode: String {
        return location.postalCode
    }

    var address: String {
        return location.address
    }

    var time: String {
        return location.time
    }

    var locality: String {
        return location.locality
    }

    var municipality: String {
        return location.municipality
    }

}
