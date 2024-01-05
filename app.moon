lapis = require "lapis"
tic_api = require "tic.api"
upload = require "tic.upload"

import respond_to, capture_errors from require "lapis.application"

import b36_to_n, n_to_b36 from require "utils"
import tobit from require "bit"

import Carts from require "models"

class extends lapis.Application
    @enable "etlua"

    layout: "layout"

    tic80_version: "1.1.2837"

    [home: "/"]: =>
        @page = "home"
        render: true
    [learn: "/learn"]: =>
        @page = "learn"
        render: true
    [create: "/create"]: =>
        @page = "create"
        @page_title = "Create"
        render: true
    [upload: "/upload"]: respond_to {
        GET: =>
            @page = "create"
            render: true,
        POST: =>
            @page = "create"
            upload @
    }
    [embed: "/embed"]: => render: true, layout: false
    [embed_cart: "/embed/:cart[0-9A-Za-z]"]: capture_errors {
        =>
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                @app.handle_404 @
            @cart = cart
            layout: false, render: true
        on_error: => @app.handle_404 @
    }
    [play: "/play"]: =>
        @page = "play"
        if id = tonumber(@GET.cart)
            cart_id = n_to_b36(tobit(id))
            return redirect_to: @url_for "play_cart", cart: cart_id
        @grab_bag = Carts\select "order by random() limit 3"
        @page = "play"
        render: true
    [play_cart: "/play/:cart[0-9A-Za-z]"]: capture_errors {
        =>
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                @app.handle_404 @
            @cart_id = n_to_b36(id)
            @cart = cart
            @page = "play"
            render: true
        on_error: => @app.handle_404 @
    }
    [info: "/info/:cart[0-9A-Za-z]"]: capture_errors {
        =>
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                @app.handle_404 @
            json: {
                title: cart.title,
                author: cart.author,
                desc: cart.desc,
                long_desc: cart.long_desc,
                hash: cart.hash,
                filename: cart.filename,
                creation: cart.creation,
                update: cart.update
            }
        on_error: => @app.handle_404 @
    }
    "/api": =>
        tic_api @
    handle_404: =>
        @write layout: "layout"
        @page_title = "404"
        return render: "404", status: 404