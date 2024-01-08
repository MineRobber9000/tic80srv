import create_table, rename_table, add_column, rename_column, types from require "lapis.db.schema"
import query from require "lapis.db"

{
    [1704459745]: =>
        create_table "carts", {
            {"id", types.integer(primary_key: true)},
            {"filename", types.text},
            {"title", types.text},
            {"author", types.text},
            {"desc", types.text},
            {"long_desc", types.text},
            {"hash", types.text},
            {"creation",types.text},
            {"update",types.text}
        }
    [1704497842]: =>
        create_table "users", {
            {"username", types.text},
            {"password", types.text},
            {"salt", types.text},
            {"email", types.text(null: true)}
        }
        add_column "carts", "uploader INTEGER"
        query "PRAGMA foreign_keys=off;"
        query "BEGIN transaction;"
        rename_table "carts", "_carts_old"
        create_table "carts", {
            {"id", types.integer(primary_key: true)},
            {"filename", types.text},
            {"title", types.text},
            {"author", types.text},
            {"desc", types.text},
            {"long_desc", types.text},
            {"hash", types.text},
            {"creation",types.text},
            {"update",types.text},
            {"uploader_id",types.integer(null: true)},

            "CONSTRAINT fk_uploader FOREIGN KEY (uploader) REFERENCES users (rowid)"
        }
        query "INSERT INTO carts SELECT * FROM _carts_old;"
        query "DROP TABLE _carts_old;"
        query "COMMIT;"
        query "PRAGMA foreign_keys=on;"
    [1704697001]: =>
        create_table "comments", {
            {"id", types.integer(primary_key: true)},
            {"user", types.integer},
            {"cart", types.integer},
            {"text", types.text},
            {"time", types.text},
            {"edited",types.integer(default: 0)}

            "CONSTRAINT fk_user FOREIGN KEY (user) REFERENCES users (rowid)",
            "CONSTRAINT fk_cart FOREIGN KEY (cart) REFERENCES carts (id)"
        }
    [1704708430]: =>
        create_table "favorites", {
            {"user", types.integer},
            {"cart", types.integer}

            "CONSTRAINT fk_user FOREIGN KEY (user) REFERENCES users (rowid)",
            "CONSTRAINT fk_cart FOREIGN KEY (cart) REFERENCES carts (id)"
        }
}