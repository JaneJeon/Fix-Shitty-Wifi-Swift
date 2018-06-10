# Fix Shitty Wifi, native ver.
This is an attempt to rewrite [this utility](https://github.com/JaneJeon/Fix-Shitty-Wifi) in Swift, for several reasons:
- no matter what I did, I couldn't plug all the leaks. The current "patched" version still leaks (albeit *extremely* slowly), and I tracked down the source to node's `http` module, which I can't do a thing about. By going with Swift, I was hoping to maybe plug that leak once and for all.
- the app was never meant to run on anything other than macOS, so I thought that by going native, I might get an improvement in power and memory usage since it wouldn't have to run on top of a VM (v8) anymore.

However, writing such command-line heavy app in Swift turned out to be a *huge* PITA, so I'm publishing this in hopes that someone can use this as a stepping stone. In particular, the `shell` - which runs multiple commands, all piped together - and `now` - which accounts for the changing timezone - functions might be useful for some.