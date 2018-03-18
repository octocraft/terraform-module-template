# tftest

[![Software License][ico-license]](LICENSE.md)
[![Build Status][ico-travis]][link-travis]

Terraform module template and testing suite

## Why
If you want to create and test terraform modules, you want to have one place to maintain the testing logic.

## Usage

`tftest` requires terraform to be present. You can either install it manually or get it via [sbpl](https://github.com/octocraft/sbpl). 

```BASH 
tftest [diff-file] [diff-file-wine]
```

`tftest` runs `terraform` `init`, `get`, `apply` and `destroy` and echos the output variables on success.
If called with an argument `tftest` will diff the output variables with the file provided. If `wine` is present `tftest` will execute the same steps inside the windows environment. The wine outputs are compared with the diff file, if provided. If a second argument is used, the first diff file is used for unix, the second for windows.

If a file named `outputs.diff` is present in PWD, tftest will use this file to diff the results.

### API

- `TFTEST_WINE` - set this to false, to disable testing with wine

- `TFTEST_DIFFOUTPUT` - set this to false to disable auto diffs with `outputs.diff` 

## License

MIT


[link-travis]: https://travis-ci.org/octocraft/tftest

[ico-license]: https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square
[ico-travis]: https://img.shields.io/travis/octocraft/tftest/master.svg?style=flat-square
