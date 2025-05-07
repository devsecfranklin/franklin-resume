# lab-gui

## includes

The include paths are defined in the "includePath" setting in a file called c_cpp_properties.json located in the .vscode directory in the opened folder.

## building

```sh
export PKG_CONFIG="/usr/bin/pkg-config"
#sudo apt-get install libgtk2.0-dev
export FLAGS=$(pkg-config --cflags --libs gtk+-2.0)
gcc src/main.c -o gui-test ${FLAGS}
```
