//
//  GameController.swift
//  
//
//  Created by Stephen Beitzel on 12/29/21.
//

import Foundation
import SystemPackage
import TBGSLib
import Vapor

typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

struct GameControllerKey: StorageKey {
    typealias Value = GameController
}

struct GameController: RouteCollection {
    let logger = Logger(label: "com.qbcps.tbgs.GameController")
    var games: [Game]
    var openResources: [UnsafeMutableRawPointer] = []

    init(pluginDir: String) {
        var loadedGames = [Game]()

        // MARK: platform-specific extension for a shared library
        let librarySuffix = Environment.get("SHARED_LIB_EXTENSION") ?? ".dylib"

        do {
            logger.debug("Looking for game plugins in path: \(pluginDir)")
            for fileName in try FileManager.default.contentsOfDirectory(atPath: pluginDir) where fileName.hasSuffix(librarySuffix) {
                var path = FilePath(pluginDir)
                path.append(fileName)
                if let openRes = dlopen(path.string, RTLD_NOW|RTLD_LOCAL) {
                    logger.info("Found game plugin at: \(path.string)")
                    let symbolName = "createGamePlugin"
                    let symbol = dlsym(openRes, symbolName)
                    if symbol != nil {
                        openResources.append(openRes)
                        let function: InitFunction = unsafeBitCast(symbol, to: InitFunction.self)
                        let pluginPointer = function()
                        let gameBuilder = Unmanaged<GameBuilder>.fromOpaque(pluginPointer).takeRetainedValue()
                        let game = gameBuilder.build()
                        logger.info("Loaded game: \(game.shortName)")
                        loadedGames.append(game)
                    } else {
                        dlclose(openRes)
                        logger.error("error loading library: symbol \(symbolName) not found, path: \(fileName)")
                    }
                } else {
                    if let err = dlerror() {
                        logger.error("error opening library: \(String(format: "%s", err)), path: \(fileName)")
                    } else {
                        logger.error("error opening library: unknown error, path: \(fileName)")
                    }
                }
            }
        } catch {
            logger.error("error looking for game plugins: \(error.localizedDescription)")
        }
        
        self.games = loadedGames
    }

    func boot(routes: RoutesBuilder) throws {
        let gameRoutes = routes.grouped("games")
        gameRoutes.get("list", use: listGames)

        let apiRoutes = routes.grouped(["v1", "games"])
        apiRoutes.get("list", use: apiList)
    }

    func gameList() -> [GameListing] {
        games.map({ GameListing($0) })
    }

    func apiList(req: Request) async throws -> [GameListing] {
        gameList()
    }

    func listGames(req: Request) async throws -> View {
        struct GamesData: Codable {
            let title: String
            let games: [GameListing]
        }

        let context = GamesData(title: "Game List",
                                games: gameList())
        return try await req.view.render("gameList", context)
    }

    public func shutdown() {
        logger.info("Closing game plugins...")
        for res in openResources {
            dlclose(res)
        }
        logger.info("Closed \(openResources.count) plugins")
    }
}

struct GameListing: Content {
    let id: UUID
    let name: String
    let description: String

    init(_ game: Game) {
        self.id = game.id
        self.name = game.shortName
        self.description = game.description
    }
}
