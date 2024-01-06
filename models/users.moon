import Model from require "lapis.db.model"
import query from require "lapis.db"

class Users extends Model
    get_carts: (order_by) =>
        if not order_by
            order_by = "[update] desc"
        Carts = require"models".Carts
        Carts\select "where uploader_id = ? order by #{order_by}", @rowid!
    rowid: =>
        res = query "select rowid from users where username = ?", @username
        res[1].rowid
    @get_one: (query="", ...) =>
        results = @select query.." limit 1", ...
        results[1]
    link_to: (req) =>
        req\url_for 'user_profile', username: @username