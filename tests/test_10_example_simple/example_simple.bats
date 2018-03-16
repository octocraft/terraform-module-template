#!/usr/bin/env bats

@test "run" {

    run ./sbpl.sh . tftest.sh
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "1..1" ]
    [ "${lines[1]}" = "ok 1 test_01_foobar" ]
}

