get_version = require "tic.version"
dir_listing = require "tic.dir"

return (doJSON) =>
    @write layout: false, content_type: (if doJSON then "application/json" else "text/lua")
    switch @GET["fn"]
        when "version"
            return get_version @, doJSON
        when "dir"
            dir = @GET["path"]
            -- if there isn't a path, default to the base directory
            if dir==nil or dir==true
                dir = ""
            return dir_listing self, dir, doJSON
        else
            return @app.handle_404 @