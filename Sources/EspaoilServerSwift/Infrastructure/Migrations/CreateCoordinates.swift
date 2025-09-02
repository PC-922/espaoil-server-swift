import Fluent

struct CreateCoordinates: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("coordinates")
            .id()
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("coordinates").delete()
    }
}
