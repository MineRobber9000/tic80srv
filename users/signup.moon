import capture_errors, yield_error from require "lapis.application"
import Users from require "models"
import assert_valid from require "lapis.validate"
import blake2s from require "libs.sha2"

gen_salt = ->
    math.randomseed os.time!
    out = ""
    while #out<32
        out..=string.char(math.random(0x20,0x7f))
    out

salt_exists = (salt) ->
    same_salt = Users\select "where salt = ?", salt
    #same_salt > 0

username_exists = (username) ->
    same_username = Users\select "where username = ?", username
    #same_username > 0

capture_errors =>
    assert_valid @params, {
        {"username", exists: true},
        {"password", exists: true},
        {"email", exists: true, optional: true}
    }

    username = @params.username
    if username_exists username
        yield_error "Username #{username} already exists."
    
    salt = gen_salt!
    while salt_exists salt
        salt = gen_salt!
    
    password_hash = blake2s(@params.password..salt)

    user = Users\create {
        username: @params.username,
        password: password_hash,
        email: @params.email or "",
        salt: salt
    }

    @session.user = user.username

    redirect_to: @url_for("home")