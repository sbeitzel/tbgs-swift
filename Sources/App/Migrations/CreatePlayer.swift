//
//  CreatePlayer.swift
//  
//
//  Created by Stephen Beitzel on 12/30/21.
//

import Foundation
import FluentKit

extension Player {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreatePlayer" }

        func prepare(on database: Database) async throws {
            try await database.schema(Player.schema)
                .id()
                .field("username", .string, .required)
                .field("password_hash", .string, .required)
                .field("nickname", .string, .required)
                .unique(on: "username")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Player.schema).delete()
        }
    }
}
