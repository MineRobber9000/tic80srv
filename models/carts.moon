import Model from require "lapis.db.model"
class Carts extends Model
    get_uploader: =>
        if @uploader_id
            Users = require"models".Users
            ret = Users\get_one "where rowid = ?", @uploader_id
            if ret
                return ret
        return {username: 'missingno', link_to: => '#'}
    _update: (...) =>
        super\update(...)
    epoch: =>
        Y, m, d, H, M, S = @creation\match "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)Z"
        offset = os.time!-os.time(os.date "!*t")
        os.time({
            year: Y,
            month: m,
            day: d,
            hour: H,
            minute: M,
            second: S,
            isdst: false
        }) + offset
    update_score: (now) =>
        Favorites = require"models".Favorites
        favorites = #(Favorites\by_cart @id)
        time_delta = now - self\epoch!
        timebase = 12*60*60
        -- score function is based off HN/news.arc
        -- essentially, favorites are dampened by a time differential to a power
        -- this ensures that we don't end up like the OG site, where 8-bit panda is
        -- 7 years old and permanently fixed to the top of "top rated" since it has
        -- 162 likes and nobody else can get that many
        @_update {
            score: math.floor((favorites/(math.max(1,time_delta/timebase))^1.8)*100000)
        }