lapis = require "lapis"
tic_api = require "tic.api"
upload = require "tic.upload"

import respond_to, capture_errors from require "lapis.application"

import b36_to_n from require "utils"

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