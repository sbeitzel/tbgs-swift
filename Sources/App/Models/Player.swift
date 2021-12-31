//
//  Player.swift
//  
//
//  Created by Stephen Beitzel on 12/30/21.
//

import Fluent
import Foundation
import Vapor

final class Player: Model, Content {
    static let schema = "players"

    @ID(key: .id) var id: UUID?
    @Field(key: "username") var userName: String
    @Field(key: "password_hash") var passwordHash: String
    @Field(key: "nickname") var nickname: String

    init() {}

    init(id: UUID? = nil,
         userName: String,
         passwordHash: String,
         nickname: String
    ) {
        self.id = id
        self.userName = userName
        self.passwordHash = passwordHash
        self.nickname = nickname
    }
}
