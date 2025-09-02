import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: NearGasStationController(
        gasStationPersister: GasStationPersisterPostgres(db: app.db),
        gasStationRetriever: GasStationRetrieverFromAPI(client: app.client)
    ))
}
