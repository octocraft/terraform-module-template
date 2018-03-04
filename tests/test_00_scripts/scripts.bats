#!/usr/bin/env bats

@test "sbpl_mock_fake.bash" {
    run ./sbpl_mock_fake.bash
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
