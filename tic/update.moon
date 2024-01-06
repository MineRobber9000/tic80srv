import capture_errors, yield_error from require "lapis.application"
import assert_valid from require "lapis.validate"
import filename, has_tic_ext, write_file, copy_file, n_to_b36, contains_banned_word from require "utils"
import sha256 from require "libs.sha2"
import Carts from require "models"
require"lfs"
import mkdir from lfs
get_metadata = require "tic.metatags"

capture_errors =>
    now = os.date("!%Y-%m-%dT%H:%M:%SZ")
    if file = @POST["cart"]
        if file.filename~=''
            fn = filename(file.filename)
            if not has_tic_ext fn
                yield_error "Cartridge must be a TIC-80 cartridge"
            hash = sha256(file.content)
            if @cart.hash == hash
                yield_error "Can't replace a cart with itself"
            hash_carts = Carts\select "where hash = ?", hash
            if #hash_carts>0
                oldcartid = n_to_b36(hash_carts[1].id)
                yield_error "This cart is already uploaded! (ID: #{oldcartid})"
            save_filename = @cart.filename
            old_hash = @cart.hash
            @cart\_update {
                :hash,
                update: now,
            }
            mkdir("cart/#{hash}")
            write_file("cart/#{hash}/#{save_filename}",file.content)
            copy_file("cover.gif","cart/#{hash}/cover.gif")
            os.execute "/usr/bin/python3 tools/cartridge_to_cover.py cart/#{hash}/#{save_filename} cart/#{hash}/cover.gif"
            os.remove "cart/#{old_hash}/cover.gif"
            os.remove "cart/#{old_hash}/#{save_filename}"
    if title = @POST["title"]
        if title~=""
            @cart\_update {
                :title,
                update: now
            }
    if author = @POST["author"]
        if author~=""
            @cart\_update {
                :author,
                update: now
            }
    if desc = @POST["desc"]
        if desc~=""
            @cart\_update {
                :desc,
                update: now
            }
    if long_desc = @POST["long_desc"]
        if long_desc~=""
            @cart\_update {
                :long_desc,
                update: now
            }
    redirect_to: @url_for "play_cart", cart: @cart_id
