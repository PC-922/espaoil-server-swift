import Fluent

struct CreateGasStations: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("gas_stations")
            .id()
            .field("name", .string, .required)
            .field("location_id", .uuid, .required, .references("locations", "id", onDelete: .cascade))
            .field("prices", .json, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("gas_stations").delete()
    }
}
  