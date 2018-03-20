#!/bin/bash
[ -f "foo.bar" ] && [ "foo-bar" = "$( < foo.bar)" ] && exit 0 || exit 1
