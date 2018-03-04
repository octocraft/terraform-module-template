#!/bin/bash
set -eu

# bash testing framwork
sbpl_get 'archive' 'bats' '0.4.0' 'https://github.com/sstephenson/bats/archive/v${version}.zip' './${name}-${version}/bin'

# terraform
source ../sbpl-pkg.sh

