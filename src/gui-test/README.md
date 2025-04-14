#

```sh
sudo apt-get install libgtk2.0-dev
gcc main.c -o gui-test `pkg-config --cflags --libs gtk+-2.0`
```
