import Carts from require"models"

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
    "New": "order by creation desc",
    "Recent": "order by [update] desc"
}

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