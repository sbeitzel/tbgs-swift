//
//  CreateToken.swift
//  
//
//  Created by Stephen Beitzel on 12/31/21.
//

import Foundation
import FluentKit

extension PlayerToken {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateToken" }

        func prepare(on database: Database) async throws {
            try await database.schema(PlayerToken.schema)
                .id()
                .field("value", .string, .required)
                .field("player_id", .uuid, .required, .references(Player.schema, "id"))
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(PlayerToken.schema).delete()
        }
    }
}
