# biography

## font

```sh
sudo apt update
sudo apt install -y fonts-montserrat texlive-fonts-recommended woff2
 woff2_decompress /usr/share/fonts/woff/montserrat/Montserrat-Regular.woff2
sudo mkdir -p /usr/local/share/fonts/truetype/montserrat
sudo fc-cache -f -v
tlmgr install montserrat
fc-list | grep Montserrat
sudo mktexlsr
```