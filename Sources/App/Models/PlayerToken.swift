//
//  PlayerToken.swift
//  
//
//  Created by Stephen Beitzel on 12/31/21.
//

import Fluent
import Vapor

final class PlayerToken: Model, Content {
    static let schema = "player_tokens"

    @ID(key: .id) var id: UUID?

    @Field(key: "value") var value: String
    @Parent(key: "player_id") var player: Player

    init() {}

    init(id: UUID? = nil,
         value: String,
         playerID: Player.IDValue) {
        self.id = id
        self.value = value
        self.$player.id = playerID
    }
}
