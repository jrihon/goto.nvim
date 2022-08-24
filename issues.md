When the filename contains a `-` , the file cannot be found
https://www.codexpedia.com/regex/regex-symbol-list-and-regex-examples/

The problem is regex.
The `-` symbol indicates a range, so the regex uses it as such.
This needs to be fixed with an escape character `\`

When the filename contains a `_`, the file can be found
