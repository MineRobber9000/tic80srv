import capture_errors, yield_error from require "lapis.application"
import Users from require "models"
import assert_valid from require "lapis.validate"
import blake2s from require "libs.sha2"

get_user = (username) ->
    users = Users\select "where username = ?", username
    users[1]

capture_errors =>
    assert_valid @params, {
        {"username", exists: true},
        {"password", exists: true}
    }

    user = get_user(@params.username)
    if not user
        yield_error "Incorrect username or password."
    
    password_hash = blake2s(@params.password..user.salt)

    unless user.password == password_hash
        yield_error "Incorrect username or password."

    @session.user = user.username

    redirect_target = @params.return_to
    if (not redirect_target) or (redirect_target == true)
        redirect_target = @url_for "home"

    redirect_to: redirect_target