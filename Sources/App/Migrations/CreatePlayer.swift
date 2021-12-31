//
//  CreatePlayer.swift
//  
//
//  Created by Stephen Beitzel on 12/30/21.
//

import Foundation
import FluentKit

struct CreatePlayer: Migration {
    func prepare(on database: Database) async {
        await database.schema(Player.schema)
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .field("nickname", .string, .required)
            .create()
    }

    func revert(on database: Database) async {
        await database.schema(Player.schema).delete()
    }

}
