#!/usr/bin/env bats

@test "basic" {
    cd ../../examples/basic/tests
    ./tftest.sh
}

@test "verify" {
    cd ../../examples/verify/tests
    ./tftest.sh
}

@test "simple" {

    # Mock env
    ln -fs ../../../tests/vendor .
    export PATH="$PWD/vendor:$PATH"

    cd ../../examples/simple/tests
    ./test.sh
}

