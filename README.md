# tic80srv

(The foundations of a possible) new TIC-80 site. Written in [lapis][] and 
[moonscript][].

Before running for the first time, run `lapis migrate` to create the DB.

In its current state, it's just about got feature parity with the original
site, save for the categories (which will be implemented as a tagging
system when they do get implemented).

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

To use the site, navigate to `http://localhost:8080`. To upload carts, start
by creating an account. Either go to `http://localhost:8080/signup` directly,
or you can click "sign in" on the navbar to get to the signin page, from which
you can click a link to sign up. Enter a username and password, click "sign up",
and you should be back at the homepage. Click on your username, which should
take you to your profile page, then click the "upload" button in the bottom left
corner.

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
