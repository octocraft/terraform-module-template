#!/bin/bash
set -eu

# Check if Terraform is present
if ! [ -x "$(command -v terraform 2>/dev/null)" ]; then
    echo 'error: terraform not found in $PATH'
    exit 2
fi

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

# run test
set +e
    output=$(run_test 2>&1) 
    result=$?
set -e

if [ "$result" -eq 0 ]; then
    
    outputs=$(echo "$output" | grep -A 2 "^Outputs:$" | grep -e '^[^\s=]* = ')

    if [ ! -z ${1+x} ] && [ -f "$1" ]; then
        [ "$outputs" = "$(< "outputs.diff")" ]
        result=$?

        if [ "$result" -eq 0 ]; then
            output=$(printf "%s\n%s" "$output" "outputs do not match with ouputs.diff")
        fi
    else
        echo "$outputs"
    fi
              
else
    echo "$output"  
fi

exit $result
