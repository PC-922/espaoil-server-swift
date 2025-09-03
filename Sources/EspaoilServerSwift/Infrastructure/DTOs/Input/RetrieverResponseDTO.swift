struct RetrieverResponseDTO: Codable {
    let date: String?
    let prices: [GasStationInputDTO]
    let note: String?
    let result: String?

    enum CodingKeys: String, CodingKey {
        case date = "Fecha"
        case prices = "ListaEESSPrecio"
        case note = "Nota"
        case result = "Resultado"
    }
}
