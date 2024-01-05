import config from require "lapis.config"

config "development", ->
    server "nginx"
    code_cache "off"
    num_workers "1"
    port 8080
    sqlite ->
        database "development.sqlite"
