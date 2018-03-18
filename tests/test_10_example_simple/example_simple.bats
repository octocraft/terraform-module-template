#!/usr/bin/env bats

@test "run" {

    export TFTEST_WINE=false

    run ./sbpl test . tftest.sh
    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[test_01_foobar]" ]
    [ "${lines[1]}" = "value = foo-bar" ]
}

