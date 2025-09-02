import Fluent

struct CreateLocations: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("locations")
            .id()
            .field("postalCode", .string, .required)
            .field("address", .string, .required)
            .field("time", .string, .required)
            .field("coordinates_id", .uuid, .required, .references("coordinates", "id", onDelete: .cascade))
            .field("municipality", .string, .required)
            .field("province", .string, .required)
            .field("locality", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("locations").delete()
    }
}
