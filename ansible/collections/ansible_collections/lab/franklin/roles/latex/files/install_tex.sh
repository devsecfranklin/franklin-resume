Non-interactive default installation on anything but Windows:

cd /tmp # working directory of your choice
Download: wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
           or: curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
(or via whatever other method you like)
zcat < install-tl-unx.tar.gz | tar xf - # note final - on that command line
cd install-tl-2*
perl ./install-tl --no-interaction # as root or with writable destination
# may take several hours to run
Finally, prepend /usr/local/texlive/YYYY/bin/PLATFORM to your PATH,
e.g., /usr/local/texlive/2025/bin/x86_64-linux
Changing defaults:

The default paper size is a4. If you want the default to be letter, add --paper=letter to the install-tl command.
By default, everything is installed (7+GB).
To install a smaller scheme, pass --scheme=scheme to install-tl. For example, --scheme=small corresponds to the BasicTeX variant of MacTeX.
To omit installation of the documentation resp. source files, pass --no-doc-install --no-src-install to install-tl.
To change the main installation directories (rarely needed), add --texdir=/your/install/dir to install-tl. To change the location of the per-user directories (where TEXMFHOME and others will be found), specify --texuserdir=/your/dir.
To change anything and everything else, omit the --no-interaction. Then you are dropped into an interactive installation menu.
