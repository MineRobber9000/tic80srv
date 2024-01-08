import Model from require "lapis.db.model"
import query from require "lapis.db"
models = require "models"

class Comments extends Model
    get_commenter: =>
        return models.Users\get_one "where rowid = ?", @user
    get_cart: =>
        return models.Carts\find @cart
    @get_comments_for_cart: (cart_id) =>
        return self\select "where cart = ?", cart_id
    @next_id: =>
        highest_id = self\select "order by id desc limit 1"
        if #highest_id==0 -- no comments
            return 0
        return highest_id[1].id+1