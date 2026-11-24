# C-fun

Drop in a `.c` file with its own `main`.

```sh
./cfun.sh run program.c  # build and run
./cfun.sh program.c      # build only -> build/program
```

Need a library? Put its `pkg-config` name on the first line, e.g.
`// cfun: raylib`. Separate multiple names with spaces. For Raylib on macOS:
`brew install pkgconf raylib`.
