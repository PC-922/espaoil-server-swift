enum EspaOilExceptions: Error {
    case failedToQueryNearGasStations
    case failedToReplaceGasStations
    case failedToRetrieveGasStations
    case failedToRetrieveNearGasStations
    case failedToUpdateGasStation

    var localizedDescription: String {
        switch self {
        case .failedToQueryNearGasStations:
            return "Failed to query near gas stations."
        case .failedToReplaceGasStations:
            return "Failed to replace gas stations in database."
        case .failedToRetrieveGasStations:
            return "Failed to retrieve gas stations from the URL source."
        case .failedToRetrieveNearGasStations:
            return "Failed to retrieve near gas stations."
        case .failedToUpdateGasStation:
            return "Failed to update gas stations."
        }
    }
}
