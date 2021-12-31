//
//  PlayerController.swift
//  
//
//  Created by Stephen Beitzel on 12/30/21.
//

import Fluent
import Vapor

extension Player {
    struct Registration: Content {
        var userName: String
        var password: String
        var confirmPassword: String
        var nickName: String
    }
}

extension Player.Registration: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userName", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension Player: ModelAuthenticatable, ModelCredentialsAuthenticatable {
    static let usernameKey = \Player.$userName
    static let passwordHashKey = \Player.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension Player {
    func generateToken() throws -> PlayerToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            playerID: self.requireID()
        )
    }
}

extension PlayerToken: ModelTokenAuthenticatable {
    static let valueKey = \PlayerToken.$value
    static let userKey = \PlayerToken.$player

    var isValid: Bool { true } // if we want tokens to expire, we update this
}

struct PlayerController: RouteCollection {
    static func makeAuthenticatedRoutesBuilder(_ from: RoutesBuilder) -> RoutesBuilder {
        from.grouped(Player.authenticator())
            .grouped(PlayerToken.authenticator())
            .grouped(Player.guardMiddleware())
    }

    func boot(routes: RoutesBuilder) throws {
        let apiPlayers = routes.grouped(["v1", "player"])

        apiPlayers.post("register", use: register)

        let authenticated = PlayerController.makeAuthenticatedRoutesBuilder(apiPlayers)
        authenticated.post("login", use: login)
    }

    func register(req: Request) async throws -> Player {
        try Player.Registration.validate(content: req)
        let registration = try req.content.decode(Player.Registration.self)
        guard registration.password == registration.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let player = try Player(userName: registration.userName,
                                passwordHash: Bcrypt.hash(registration.password),
                                nickname: registration.nickName.isEmpty ? registration.userName : registration.nickName)
        try await player.save(on: req.db)
        return player
    }

    func login(req: Request) async throws -> PlayerToken {
        let player = try req.auth.require(Player.self)
        let token = try player.generateToken()
        try await token.save(on: req.db)
        return token
    }
}
