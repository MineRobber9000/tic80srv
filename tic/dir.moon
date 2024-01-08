import Carts, Users from require"models"

gen_listing = (folders, files) ->
    out = "folders =\n{\n"
    for folder in *folders
        out ..= "\t{ name = #{string.format('%q',folder)} },\n"
    out ..= "\n}\n\nfiles =\n{\n"
    for file in *files
        out ..= "\t{ name = #{string.format('%q',file.name..'.tic')}, hash = #{string.format('%q',file.hash)}, id = #{file.id}, filename = #{string.format('%q',file.filename)} },\n"
    out ..="\n}"
    return out

dir_queries = {
    "": "order by [update] desc limit 5",
    "Devs": "where 1==1" -- dummy query; when you cd into Devs, it'll run its own code
}

sort_queries = require"sort_queries"
for k,v in pairs(sort_queries)
    dir_queries[v.name] = v.query

get_subdirs = (dir) ->
    there = {}
    if dir==""
        for k,v in pairs(dir_queries)
            k\gsub("^([^/]+)/?",(d) -> there[d]=true)
    else
        for k,v in pairs(dir_queries)
            k\gsub("^#{dir}/([^/]+)/?",(d) -> there[d]=true)
    dirs = {}
    for k,v in pairs(there)
        table.insert(dirs,k)
    dirs

dir_listing = (dir) =>
    if dir=="Devs"
        users = Users\select "order by username asc"
        dirs = {}
        for _, user in ipairs(users)
            table.insert(dirs, user.username)
        files = {}
        return gen_listing(dirs,files)
    if username = dir\match "Devs/([^/]+)$"
        user = Users\get_one "where username = ?", username
        return @app.handle_404 @ unless user
        carts = user\get_carts "score desc"
        files = {}
        for cart in *carts
            file = {}
            file.name = cart.title
            file.hash = cart.hash
            file.id = cart.id
            file.filename = cart.filename
            table.insert(files,file)
        dirs = {}
        for _, v in pairs(sort_queries)
            table.insert dirs, v.name
        table.sort(dirs)
        return gen_listing(dirs,files)
    username, sort = dir\match "Devs/(.-)/([^/]+)"
    if username and sort
        user = Users\get_one "where username = ?", username
        return @app.handle_404 @ unless user
        query = ""
        for _, v in pairs(sort_queries)
            if v.name==sort
                query = v.query\gsub("^order by ","")
        if query==""
            return @app.handle_404 @
        carts = user\get_carts query
        files = {}
        for cart in *carts
            file = {}
            file.name = cart.title
            file.hash = cart.hash
            file.id = cart.id
            file.filename = cart.filename
            table.insert(files,file)
        return gen_listing({},files)
    query = dir_queries[dir]
    return @app.handle_404 @ unless query
    files = {}
    carts = Carts\select query
    for cart in *carts
        file = {}
        file.name = cart.title
        file.hash = cart.hash
        file.id = cart.id
        file.filename = cart.filename
        table.insert(files,file)
    return gen_listing(get_subdirs(dir),files)

return dir_listing