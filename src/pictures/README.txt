# pictures

## install magededup

```sh
git clone https://github.com/idealo/imagededup.git
cd imagededup
pip install "cython>=0.29"
python setup.py install
```

## local build env testing

```sh
python3 -m venv _build
. _build/bin/activate.fish || . _build/bin/activate
# install latest vertsion of pip and wheel to fix the error:
# ModuleNotFoundError: No module named 'pip._vendor.packaging'
curl -sS https://bootstrap.pypa.io/get-pip.py | python3
python3 -m pip install -r requirements.txt
```
