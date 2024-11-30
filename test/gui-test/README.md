#

```sh
sudo apt-get install libgtk2.0-dev
gcc main.c -o p1 `pkg-config --cflags --libs gtk+-2.0`
```
