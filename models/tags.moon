import Model from require "lapis.db.model"
import query from require "lapis.db"
models = require "models"

class Tags extends Model
    get_carts: =>
        Carts\select "INNER JOIN carts_tags ct ON ct.cart = carts.id WHERE ct.tag = ?", @id