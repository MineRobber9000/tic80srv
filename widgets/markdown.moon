import Widget from require "lapis.html"
markdown = require "markdown"

class MarkdownWidget extends Widget
    content: =>
        raw (markdown(@text))