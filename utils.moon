import assert_error from require "lapis.application"
b36alph = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

filename = (path) ->
    string.sub(path,string.find(path,'[%w%s!-.0-={-|]+[_%.].+'),#path)

has_tic_ext = (fn) -> -- eventually I want to be able to take in PNG and projects but for now just .tic
    switch string.sub(fn, string.find(fn, '%.[^.]+$'))
        -- when '.png'
        --     return true
        when '.tic'
            return true
        -- when '.fnl'
        --     return true
        -- when '.janet'
        --     return true
        -- when '.js'
        --     return true
        -- when '.lua'
        --     return true
        -- when '.moon'
        --     return true
        -- when '.rb'
        --     return true
        -- when '.py'
        --     return true
        -- when '.scm'
        --     return true
        -- when '.nut'
        --     return true
        -- when '.wasmp'
        --     return true
        -- when '.wren'
        --     return true
    false

write_file = (fn, content) ->
    file = assert_error io.open(fn,"wb")
    file\write content
    file\close!

copy_file = (src, dst) ->
    file = assert_error io.open(src,"rb")
    contents = file\read "*a"
    file\close!
    file = assert_error io.open(dst,"wb")
    file\write contents
    file\close!

n_to_b36 = (n) ->
    out = ""
    while n>0
        q, r = math.floor(n/36), n%36
        out = string.sub(b36alph,r+1,r+1)..out
        n=q
    while #out<6
        out = "0"..out
    out

b36_to_n: (b36) ->
    n = 0
    for i=1,#b36 do
        c=string.sub(b36,i,i)
        c=string.upper(c)
        d=string.find(b36alph,c)
        unless d
            yield_error "Invalid base36 character!"
        d-=1
        n=n*36+d
    n

{
    :filename
    
    :has_tic_ext
    
    :write_file
    
    :copy_file

    :n_to_b36
    
    :b36_to_n
}