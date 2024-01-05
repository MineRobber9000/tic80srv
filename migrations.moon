import create_table, add_column, types from require "lapis.db.schema"

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
}