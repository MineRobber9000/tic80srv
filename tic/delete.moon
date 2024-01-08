import capture_errors, yield_error from require "lapis.application"
import b36_to_n from require "utils"
import Carts, Users from require "models"
require"lfs"
import rmdir from lfs
csrf = require "lapis.csrf"
refresh_scores = require "refresh_scores"

capture_errors {
    =>
        csrf.assert_token @
        id = b36_to_n(@params.cart)
        cart = Carts\find id
        if not cart
            return @app.handle_404 @
        user = Users\get_one "where username = ?", @session.user
        unless cart.uploader_id == user\rowid!
            @page_title = "403"
            return status: 403, render: "403"
        os.remove "cart/#{cart.hash}/cover.gif"
        os.remove "cart/#{cart.hash}/#{cart.filename}"
        lfs.rmdir "cart/#{cart.hash}"
        cart\delete!
        refresh_scores!
        redirect_to: @url_for "profile"
    on_error: =>
        redirect_to: @url_for "play_cart", cart: @params.cart
}