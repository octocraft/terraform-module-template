#!/usr/bin/env bats

@test "TFTEST_WINE false / no wine" {
    
    run ./tftest.sh
    [ "$status" -eq 0 ]
    [ "$output" = "1..0" ]
}
