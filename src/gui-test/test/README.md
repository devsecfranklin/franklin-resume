# test

The tests directory contains a test file for each module in the src directory

## clang-format

```sh
#!/bin/sh
# Pre-commit hook for formatting changes
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.[ch]pp$') # Adjust extensions as needed
if [ "$files" != "" ]; then
    clang-format -i $files
    git add $files
fi
```
