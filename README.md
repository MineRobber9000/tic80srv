# tic80srv

(The foundations of a possible) new TIC-80 site. Written in [lapis][] and 
[moonscript][].

Before running for the first time, run `lapis migrate` to create the DB.

In its current state, it's just about enough to upload carts (no account system
yet) and have them playable from inside TIC-80.

[lapis]: https://github.com/leafo/lapis
[moonscript]: https://github.com/leafo/moonscript

## How to use

First, install [openresty][], as well as [luarocks][] for Lua 5.1. Then,
install the rocks:

```
luarocks install lapis luafilesystem lsqlite3 moonscript
```

Next, compile the code:

```
make # or, alternatively:
moonc .
```

Next, create the database:

```
lapis migrate
```

Finally, start up the server:

```
make server
```

To upload carts, navigate to `http://localhost:8080/upload`. Note that only
`.tic` cartridges can be uploaded at the moment, and covers will not work in
`surf` (they all show the "this a test lmao" cover; eventually the `cover.gif`
will be programmatically created from the cart).

[openresty]: https://openresty.org/en/download.html
[luarocks]: https://luarocks.org/#quick-start

### TIC-80 build

To build a version of TIC-80 that connects to your local tic80srv instance,
change the following lines in `src/studio/system.h`:

```c
// formerly:
#define TIC_HOST "tic80.com"
#define TIC_WEBSITE "https://" TIC_HOST
// change it to:
#define TIC_HOST "localhost:8080"
#define TIC_WEBSITE "http://" TIC_HOST
```

Build as normal.
