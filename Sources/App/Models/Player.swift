//
//  Player.swift
//  
//
//  Created by Stephen Beitzel on 12/30/21.
//

import Fluent
import Foundation
import Vapor

class Player: Model, Content {
    static let schema = "players"

    @ID(key: .id) var id: UUID?
    @Field(key: "username") var userName: String
    @Field(key: "password") var password: String
    @Field(key: "nickname") var nickname: String

    init() {}

    init(id: UUID? = nil,
         userName: String,
         password: String,
         nickname: String
    ) {
        self.id = id
        self.userName = userName
        self.password = password
        self.nickname = nickname
    }
}
