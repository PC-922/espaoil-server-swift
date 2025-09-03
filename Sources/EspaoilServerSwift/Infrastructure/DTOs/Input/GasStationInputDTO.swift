struct GasStationInputDTO: Codable {
    let postalCode: String?
    let address: String?
    let time: String?
    let latitude: String?
    let locality: String?
    let longitude: String?
    let municipality: String?
    let gas95E10Price: String?
    let gas95E5Price: String?
    let gas95E5PremiumPrice: String?
    let gas98E10Price: String?
    let gas98E5Price: String?
    let province: String?
    let name: String?
    let gasoilA: String?
    let gasoilB: String?
    let gasoilPremium: String?
    let biodieselPrice: String?
    let bioethanolPrice: String?
    let gasNaturalCompressedPrice: String?
    let gasNaturalLiquefiedPrice: String?
    let liquefiedPetroleumGasesPrice: String?
    let hydrogenPrice: String?
}

extension GasStationInputDTO {
    enum CodingKeys: String, CodingKey {
        case postalCode = "C.P."
        case address = "Dirección"
        case time = "Horario"
        case latitude = "Latitud"
        case locality = "Localidad"
        case longitude = "Longitud (WGS84)"
        case municipality = "Municipio"
        case gas95E10Price = "Precio Gasolina 95 E10"
        case gas95E5Price = "Precio Gasolina 95 E5"
        case gas95E5PremiumPrice = "Precio Gasolina 95 E5 Premium"
        case gas98E10Price = "Precio Gasolina 98 E10"
        case gas98E5Price = "Precio Gasolina 98 E5"
        case province = "Provincia"
        case name = "Rótulo"
        case gasoilA = "Precio Gasoleo A"
        case gasoilB = "Precio Gasoleo B"
        case gasoilPremium = "Precio Gasoleo Premium"
        case biodieselPrice = "Precio Biodiesel"
        case bioethanolPrice = "Precio Bioetanol"
        case gasNaturalCompressedPrice = "Precio Gas Natural Comprimido"
        case gasNaturalLiquefiedPrice = "Precio Gas Natural Licuado"
        case liquefiedPetroleumGasesPrice = "Precio Gases Licuados del Petróleo"
        case hydrogenPrice = "Precio Hidrógeno"
    }
}

extension GasStationInputDTO {
    func toDomain() throws -> GasStation {
        guard
            let name = self.name,
            let postalCode = self.postalCode,
            let address = self.address,
            let time = self.time,
            let latitude = Double((self.latitude ?? "").replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)),
            let longitude = Double((self.longitude ?? "").replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)),
            let municipality = self.municipality,
            let province = self.province,
            let locality = self.locality 
        else {
            throw EspaOilExceptions.failedToRetrieveGasStations
        }
        return GasStation(
            name: name,
            location: .init(
                postalCode: postalCode,
                address: address,
                time: time,
                coordinates: try Coordinates(
                    latitude: latitude, 
                    longitude: longitude
                ),
                municipality: municipality,
                province: province,
                locality: normalizeLocality(value: locality)
            ),
            prices: normalizePrices()
        )
    }

    private func normalizePrices() -> [String: Double] {
       let prices: [String: Double?] = [
            "GASOLINA_95_E10": Double((self.gas95E10Price ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLINA_95_E5": Double((self.gas95E5Price ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLINA_95_E5_PREMIUM": Double((self.gas95E5PremiumPrice ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLINA_98_E10": Double((self.gas98E10Price ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLINA_98_E5": Double((self.gas98E5Price ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLEO_A": Double((self.gasoilA ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLEO_B": Double((self.gasoilB ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASOLEO_PREMIUM": Double((self.gasoilPremium ?? "").replacingOccurrences(of: ",", with: ".")),
            "BIODIESEL": Double((self.biodieselPrice ?? "").replacingOccurrences(of: ",", with: ".")),
            "BIOETANOL": Double((self.bioethanolPrice ?? "").replacingOccurrences(of: ",", with: ".")),
            "GAS_NATURAL_COMPRIMIDO": Double((self.gasNaturalCompressedPrice ?? "").replacingOccurrences(of: ",", with: ".")),
            "GAS_NATURAL_LICUADO": Double((self.gasNaturalLiquefiedPrice ?? "").replacingOccurrences(of: ",", with: ".")),
            "GASES_LICUADOS_DEL_PETROLEO": Double((self.liquefiedPetroleumGasesPrice ?? "").replacingOccurrences(of: ",", with: ".")),
            "HIDROGENO": Double((self.hydrogenPrice ?? "").replacingOccurrences(of: ",", with: "."))
        ]
        return prices.compactMapValues { $0 }
    }

    private func normalizeLocality(value: String) -> String {
        value
            .lowercased()
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}