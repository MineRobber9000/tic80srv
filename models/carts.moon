import Model from require "lapis.db.model"
class Carts extends Model
    get_uploader: =>
        if @uploader_id
            Users = require"models".Users
            ret = Users\get_one "where rowid = ?", @uploader_id
            if ret
                return ret
        return {username: 'missingno', link_to: => '#'}