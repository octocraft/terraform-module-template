#!/usr/bin/env bats

@test "TFTEST_WINE unset / no wine" {
    
    export PATH="/bin"    
    run ./sbpl.sh . tftest.sh
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
