-- For refreshing cart scores
-- See models/cart.moon for score function
->
    Carts = require"models".Carts
    now = os.time!
    for cart in *(Carts\select "where 1=1")
        cart\update_score now