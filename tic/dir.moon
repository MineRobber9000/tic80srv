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

dir_listing = (dir) =>
    return @app.handle_404 @ unless dir=="" or dir=="New"
    files = {}
    carts = Carts\select "order by "..(dir=="New" and "creation desc" or "id")
    for cart in *carts
        file = {}
        file.name = cart.title
        file.hash = cart.hash
        file.id = cart.id
        file.filename = cart.filename
        table.insert(files,file)
    dirs = {}
    if dir=="" then dirs[1]="New"
    return gen_listing(dirs,files)

return dir_listing