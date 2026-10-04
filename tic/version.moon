json = require "cjson"

get_version = =>
    version = @app.tic80_version
    major, minor, patch = version\match "^(%d+)%.(%d+)%.(%d+)"
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    return json.encode({:version, :major, :minor, :patch})

return get_version