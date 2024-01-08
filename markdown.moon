markdown = require"libs.markdown"

allowed_tags = {
    ["p"]: true
    ["strong"]: true
    ["h1"]: true
    ["h2"]: true
    ["h3"]: true
    ["h4"]: true
    ["h5"]: true
    ["h6"]: true
    ["em"]: true
    ["ul"]: true
    ["ol"]: true
    ["li"]: true
    ["blockquote"]: true
    ["pre"]: true
    ["code"]: true
    ["hr"]: true
    ["a"]: true
    ["img"]: true
}

attr_patterns = {
    ["a"]: {
        "^ href=\".-\"$",
        "^ href=\".-\" title=\".-\"$"
    },
    ["img"]: {
        "^ src=\".-\" alt=\".-\"/$",
        "^ src=\".-\" alt=\".-\" title=\".-\"/$",
    }
}

replace_tags = setmetatable {
    ["h1"]: "h4",
    ["h2"]: "h5",
    ["h3"]: "h6"
    ["h4"]: "p class='mb-1'"
    ["h5"]: "p class='mb-1'"
    ["h6"]: "p class='mb-1'"
}, {
    ["__index"]: (k) =>
        return k
}

filter_attrs = (tagname, attrs) ->
    if attrs=="" -- empty attrs are always okay
        return true
    patterns = attr_patterns[tagname]
    unless patterns
        return false
    if type(patterns)=="string"
        patterns = { patterns }
    for pattern in *patterns
        if attrs\match pattern
            return attrs
    false

(text) ->
    output = markdown text
    output\gsub "<(/?)(%w+)(.-)>", (slash,tagname,attrs) ->
        if allowed_tags[tagname] and filter_attrs(tagname, attrs)
            return "<#{slash}#{replace_tags[tagname]}#{attrs}>"
        return "&lt;#{slash}#{tagname}#{attrs}&gt;"