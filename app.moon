lapis = require "lapis"
tic_api = require "tic.api"
upload = require "tic.upload"
update = require "tic.update"
delete = require "tic.delete"
signup = require "users.signup"
signin = require "users.signin"
sort_queries = require "sort_queries"
csrf = require "lapis.csrf"

import respond_to, capture_errors from require "lapis.application"

import b36_to_n, n_to_b36 from require "utils"
import tobit from require "bit"

import Carts, Users from require "models"

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
            unless @session.user
                return redirect_to: @url_for "signin", nil, {return_to: @url_for "upload"}
            @page = "create"
            render: true,
        POST: =>
            unless @session.user
                return redirect_to: @url_for "signin", nil, {return_to: @url_for "upload"}
            user = Users\select "where username = ?", @session.user
            @user = user[1]
            @page = "create"
            upload @
    }
    [update_cart: "/update/:cart[0-9A-Za-z]"]: respond_to {
        GET: =>
            @csrf_token = csrf.generate_token @
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                return @app.handle_404 @
            cart_id = n_to_b36(id)
            unless @session.user
                return redirect_to: @url_for "signin", nil, {return_to: @url_for "update_cart", {cart: cart_id}}
            uploader = cart\get_uploader!
            unless uploader.username == @session.user
                return status: 403, render: "403"
            @cart = cart
            @cart_id = cart_id
            render: true
        POST: =>
            csrf.assert_token @
            unless @session.user
                return redirect_to: @url_for 'signin'
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                return @app.handle_404 @
            cart_id = n_to_b36(id)
            unless @session.user
                return redirect_to: @url_for "signin", nil, {return_to: @url_for "update_cart", {cart: cart_id}}
            uploader = cart\get_uploader!
            unless uploader.username == @session.user
                return status: 403, render: "403"
            @cart = cart
            @cart_id = cart_id
            @uploader = uploader
            update @
    }
    [delete_cart: "/delete/:cart[0-9A-Za-z]"]: respond_to {
        GET: =>
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                return @app.handle_404 @
            redirect_to: @url_for "play_cart", cart: n_to_b36(cart.id)
        POST: =>
            unless @session.user
                return redirect_to: @url_for 'signin'
            delete @
    }
    [embed: "/embed"]: => render: true, layout: false
    [embed_cart: "/embed/:cart[0-9A-Za-z]"]: capture_errors {
        =>
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                return @app.handle_404 @
            @cart = cart
            layout: false, render: true
        on_error: => @app.handle_404 @
    }
    [play: "/play"]: =>
        @page = "play"
        if id = tonumber(@GET.cart)
            cart_id = n_to_b36(tobit(id))
            return redirect_to: @url_for "play_cart", cart: cart_id
        if sort = @GET.sort
            if sort==true
                return render: true
            query = sort_queries[sort]
            unless query
                return @app.handle_404 @
            @carts_paginated = Carts\paginated query.query, per_page: 30
            @page = tonumber(@GET.page)
            if not @page then @page = 1
            if @page>@carts_paginated\num_pages! then @page = @carts_paginated\num_pages!
            @page_title = query.name
            return render: "play_sorted"
        @grab_bag = Carts\select "order by random() limit 3"
        @categories = {}
        for key, query in pairs(sort_queries)
            table.insert(@categories,{:key, name: query.name, sample: Carts\select query.query.." limit 3"})
        render: true
    [play_cart: "/play/:cart[0-9A-Za-z]"]: capture_errors {
        =>
            id = b36_to_n(@params.cart)
            cart = Carts\find id
            if not cart
                return @app.handle_404 @
            @csrf_token = csrf.generate_token @
            @cart_id = n_to_b36(id)
            @cart = cart
            @uploader = cart\get_uploader!
            @link_to_uploader = @uploader\link_to @
            @is_uploader = @uploader.username==@session.user
            @page = "play"
            render: true
        on_error: => @app.handle_404 @
    }
    [signin: "/signin"]: respond_to {
        GET: => render: true,
        POST: => signin @
    }
    [signup: "/signup"]: respond_to {
        GET: => render: true,
        POST: => signup @
    }
    [signout: "/signout"]: =>
        @session.user = nil
        redirect_to: @url_for "home"
    [profile: "/profile"]: =>
        if not @session.user
            return redirect_to: @url_for "signin", nil, {return_to: @url_for "profile"}
        @user = Users\get_one "where username = ?", @session.user
        @recent_carts = @user\get_carts!
        render: true
    [user_profile: "/user/:username"]: =>
        users = Users\select "where username = ?", @params.username
        @user = users[1]
        unless @user
            return @app.handle_404 @
        @recent_carts = @user\get_carts!
        render: true
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