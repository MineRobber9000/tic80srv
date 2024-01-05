import band, bor, lshift, rshift from require "bit"
import yield_error from require "lapis.application"

isspace = (c) ->
    c==" " or c=="\n" or c=="\t" or c=="\v" or c=="\f" or c=="\r"

metatag = (code, tag, comment) -> -- cf. tic_tool_metatag
    tagBuffer = string.format("%s %s:",comment,tag)
    start = string.find(code,tagBuffer,1,true)
    return unless start
    start += #tagBuffer
    _end = string.find(code,"\n",start,true)
    return unless _end
    while isspace(string.sub(code,start,start)) and start<_end
        start+=1
    while isspace(string.sub(code,_end,_end)) and _end>start
        _end-=1
    string.sub(code,start,_end)

value_in = (value, values) ->
    for v in *values
        return true if v==value
    return false

determine_comment = (text) ->
    return ";" if metatag(text,"script",";")=="fennel"
    return "#" if value_in(metatag(text,"script","#"),{"janet","ruby","python"})
    return "//" if value_in(metatag(text,"script","//"),{"js","squirrel","wren"})
    return "--" if value_in(metatag(text,"script","--"),{"lua","moon","wasm"})
    return ";;" if metatag(text,"script",";")=="scheme"
    return "--" -- default to Lua

-- there are others but these are the metadata tags we care about
metadata = {
    "title",
    "author",
    "desc"
}

(contents) -> -- this is a really basic TIC-80 cartridge file format parser
    i = 1
    code = {}
    while i<#contents
        type_b = string.byte(contents,i)
        i+=1
        chunk_type = band(type_b,31)
        bank = band(rshift(type_b,5),7)
        size = bor(string.byte(contents,i),lshift(string.byte(contents,i+1),8))
        i+=3 -- 2 byte u16 + reserved byte we don't actually care about
        if (chunk_type==5 or chunk_type==19) and size==0
            size = 65536
        if chunk_type==5
            code[bank]=string.sub(contents,i,i+size-1)
        i+=size
    text = ""
    for i=0,7
        if code[i]
            text..=code[i]
    comment = determine_comment(text)
    meta = {}
    for tag in *metadata
        meta[tag] = metatag(text,tag,comment)
    return meta