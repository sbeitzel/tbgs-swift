import Fluent
import Vapor

func routes(_ app: Application, _ gameController: GameController) throws {
    // this will look for any games in the Resources/Games directory
    try app.register(collection: gameController)

    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
}
