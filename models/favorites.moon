import Model from require "lapis.db.model"
import query from require "lapis.db"
models = require "models"

class Favorites extends Model
    get_user: =>
        return models.Users\get_one "where rowid = ?", @user
    get_cart: =>
        return models.Carts\find @cart
    @by_user: (user_id) =>
        return self\select "where user = ?", user_id
    @by_cart: (cart_id) =>
        return self\select "where cart = ?", cart_id
    @already_favorited: (user_id, cart_id) =>
        items = self\select "where user = ? and cart = ?", user_id, cart_id
        #items>0
    @favorite: (user_id, cart_id) =>
        return if self\already_favorited user_id, cart_id
        self\create {
            user: user_id,
            cart: cart_id
        }
    @unfavorite: (user_id, cart_id) => -- for some reason this has to be implemented as a raw query
        query "DELETE FROM favorites WHERE user = ? and cart = ?", user_id, cart_id