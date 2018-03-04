#!/bin/bash
set -eu

# Get Packages
./sbpl.sh

# Include Packages
export PATH="$PWD/vendor/bin/current:$PATH"

# Get test dirs
shopt -s nullglob
tests=(test*/)
total=${#tests[@]}
shopt -u nullglob

# TAP
printf "1..$total\n" 

# Test with wine (if present)
((command -v 'wine' &> /dev/null) && ([ -z "${TFTEST_WINE+x}" ] || $TFTEST_WINE)) && test_wine=true || test_wine=false

# Test function
function run_test () {

    function clean () {
        rm -rf .terraform
        rm -f terraform.tfstate
        rm -f terraform.tfstate.backup
    }

    set +e
    (
        clean
        set -e
        terraform init -input=false -no-color > /dev/null
        terraform get > /dev/null
        set +e
        terraform apply -input=false -auto-approve -no-color
        res=$?
        terraform destroy -force -no-color > /dev/null
        clean
        if [ "$res" -eq 0 ]; then return $?; else return $res; fi 
    )
    result=$?
    set -e

    return $result
}

# Loop through test folders
num=0
for subdir in test*/; do
    if [ ! -d "$subdir" ]; then continue; fi

    name=${subdir%/}
    num=$((num + 1))

    pushd "$subdir" > /dev/null

        set +e
        output=$(
            run_test 2>&1
        ) 
        result=$?
        set -e

        if [ "$result" -eq 0 ]; then
            # Test outputs
            if [ -f "outputs.diff" ]; then
                outputs=$(echo "$output" | grep -A 2 "^Outputs:$" | grep -e '^[^\s=]* = ')
                [ "$outputs" = "$(< "outputs.diff")" ]
                result=$?

                if [ "$result" -eq 0 ]; then
                    output=$(printf "%s\n%s" "$output" "outputs do not match with ouputs.diff")
                fi                
            fi
        fi
        
        if [ "$result" -eq 0 ]; then
            status="ok"
            output=""
        else
            status="not ok"
            output=$(printf "\n%s" "$output")
        fi

        printf "ok %s %s\n" $num $name $output

    popd > /dev/null

done

