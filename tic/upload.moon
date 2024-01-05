import capture_errors, yield_error from require "lapis.application"
import assert_valid from require "lapis.validate"
import filename, has_tic_ext, write_file, copy_file, n_to_b36 from require "utils"
import sha256 from require "libs.sha2"
import Carts from require "models"
require"lfs"
import mkdir from lfs
get_metadata = require "tic.metatags"

capture_errors =>
    assert_valid @POST, {
        {"cart", is_file: true},
    }
    file = @POST["cart"]
    filename = filename(file.filename)
    if not has_tic_ext filename
        yield_error "Cartridge must be a TIC-80 cartridge"
    hash = sha256(file.content)
    meta = get_metadata(file.content)
    if @POST.title~=""
        meta.title = @POST.title
    if @POST.author~=""
        meta.author = @POST.author
    if @POST.desc~=""
        meta.desc = @POST.desc
    if not meta.desc -- description is optional
        meta.desc = ""
    if not (meta.title and meta.author) -- title and author are decidedly not
        yield_error "Cart must contain title and author"
    save_filename = meta.title\lower!\gsub("%W+","_") .. ".tic"
    math.randomseed os.time!
    id = math.random(0,(36^6)-1)
    while Carts\find id
        id = math.random(0,(36^6)-1)
    now = os.date("!%Y-%m-%dT%H:%M:%SZ")
    cart = Carts\create {
        :id,
        filename: save_filename,
        title: meta.title,
        author: meta.author,
        desc: meta.desc,
        long_desc: @POST.long_desc,
        :hash,
        creation: now,
        update: now
    }
    mkdir("cart/#{hash}")
    write_file("cart/#{hash}/#{save_filename}",file.content)
    copy_file("cover.gif","cart/#{hash}/cover.gif")
    redirect_to: @url_for "play_cart", cart: n_to_b36(id)