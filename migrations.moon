import create_table, rename_table, add_column, rename_column, types from require "lapis.db.schema"
import query from require "lapis.db"

{
    [1704497842]: =>
        create_table "users", {
            {"username", types.text},
            {"password", types.text},
            {"salt", types.text},
            {"email", types.text(null: true)}
        }
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

            "CONSTRAINT fk_uploader_id FOREIGN KEY (uploader_id) REFERENCES users (rowid)"
        }
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
    [1704716466]: =>
        query "ALTER TABLE carts ADD COLUMN score INTEGER NOT NULL DEFAULT 0"

        Carts = require"models".Carts
        now = os.time!
        for cart in *(Carts\select "where 1=1")
            cart\update_score now

    [1791256924]: =>
        create_table "tags", {
            {"id", types.integer(primary_key: true)},
            {"name", types.text},
            {"description", types.text}
        }

        create_table "carts_tags", {
            {"cart", types.integer},
            {"tag", types.integer},

            "CONSTRAINT fk_cart FOREIGN KEY (cart) REFERENCES carts (id)",
            "CONSTRAINT fk_tag FOREIGN KEY (tag) REFERENCES tags (id)",
            "PRIMARY KEY (cart, tag)"
        }

        Tags = require"models".Tags
        Tags\create {
            name: "Games",
            description: "Released games."
        }
        Tags\create {
            name: "Techdemos",
            description: "Tech demos to show the capabilities of the platform."
        }
        Tags\create {
            name: "Tools",
            description: "Tools and libraries for carts."
        }
        Tags\create {
            name: "Music",
            description: "Music and sound effects."
        }
        Tags\create {
            name: "WIP",
            description: "Work in progress carts."
        }
        Tags\create {
            name: "Demoscene",
            description: "For demoscene intros/demos."
        }
        Tags\create {
            name: "Livecoding",
            description: "Carts produced during 10-60 minute coding sessions such as Bytebattles or Bytejams."
        }
}
