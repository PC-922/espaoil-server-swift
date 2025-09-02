import Foundation
import Vapor

struct NearGasStationsDTO: Content {
    let name: String
    let town: String
    let municipality: String
    let schedule: String
    let price: String
    let latitude: String
    let longitude: String

    static func fromGasStation(_ gasStation: GasStation, gasType: String) -> NearGasStationsDTO {
        return NearGasStationsDTO(
            name: gasStation.name,
            town: formattedLocality(gasStation.locality),
            municipality: gasStation.municipality,
            schedule: gasStation.time,
            price: formatDecimal(gasStation.prices[gasType] ?? 0.0),
            latitude: formatDecimal(gasStation.latitude),
            longitude: formatDecimal(gasStation.longitude)
        )
    }

    private static func formatDecimal(_ value: Double) -> String {
        return String(format: "%.3f", value)
    }

    private static func formattedLocality(_ locality: String) -> String {
        // ARTICLES_REGEX equivalente - necesitas definir los 4 grupos de captura
        let articlesRegex = "(.*)\\s?\\((OS|A|OS|A|O|LAS|AS|LA|LES|LOS|S'|EL|L'|ELS|SES|ES|SA)\\)(.*)?|(.*)"
        
        return capitalize(
            locality
                .replacingOccurrences(
                    of: articlesRegex,
                    with: "$4$2 $1$3", // Mismo patrón que en Kotlin
                    options: .regularExpression
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
                .removeExtraSpaces()
        )
    }

    private static func capitalize(_ text: String) -> String {
        let pattern = "\\b(\\w)"
        var result = text
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: text.utf16.count)
            
            // Procesar desde el final hacia el principio para evitar problemas de índices
            let matches = regex.matches(in: text, options: [], range: range).reversed()
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let uppercased = String(text[range]).uppercased()
                    result = result.replacingCharacters(in: range, with: uppercased)
                }
            }
        } catch {
            // Fallback a capitalized si falla el regex
            return text.capitalized
        }
        
        return result
    }
}

extension String {
    func removeExtraSpaces() -> String {
        return self.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
    }
}