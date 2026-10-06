json = require "libs.dkjson"

get_version = (doJSON) =>
    version = @app.tic80_version
    major, minor, patch = version\match "^(%d+)%.(%d+)%.(%d+)"
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    if doJSON
        return json.encode({:version, :major, :minor, :patch}, {keyorder:{"version", "major", "minor", "patch"}})
    else
        return "version = #{string.format('%q',version)}\nmajor = #{string.format('%d',minor)}\nminor = #{string.format('%d',minor)}\npatch = #{string.format('%d',patch)}"

return get_version