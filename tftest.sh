#!/bin/bash
set -eu

# Check if Terraform is present
if ! command -v terraform &>/dev/null; then
    echo 'error: terraform not found in $PATH'
    exit 2
fi

# Test with wine (if present)
((command -v 'wine' &> /dev/null) && ([ -z "${TFTEST_WINE+x}" ] || $TFTEST_WINE)) && test_wine=true || test_wine=false

# outputs.diff
[ -f "outputs.diff" ] && ([ -z "${TFTEST_DIFFOUTPUT+x}" ] || $TFTEST_DIFFOUTPUT) && diff_output=true || diff_output=false

# Test function
function exec_tf () {

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

function run_test () {

    # run test
    set +e
        output=$(exec_tf 2>&1)
        result=$?
    set -e

    if [ "$result" -eq 0 ]; then

        set +e
        numlines=$(echo "$output" | grep -c '^')
        outputs=$(echo "$output" | grep -A $numlines "^Outputs:$" | grep -e '^[^\s=]* = ')
        set -e

        if [ ! -z "${1+x}" ] && [ -f "$1" ]; then
            difffile="$1"
        elif $diff_output && [ -f "outputs.diff" ]; then
            difffile="outputs.diff"
        else
            difffile=""
        fi

        if [ ! -z "$difffile" ]; then

            set +e
            [ "$outputs" = "$(< "$difffile")" ]
            result=$?
            set -e

            if [ "$result" -eq 0 ]; then
                printf "success\n"
            else
                printf "%s\n%s\n" "output does not match with '$difffile':" "$outputs"
            fi
        else
            echo "$outputs"
        fi

    else
        echo "$output"
    fi

    return $result
}

run_test $@
result=$?
if [ "$result" -ne 0 ]; then exit $result; fi

if $test_wine; then
    (
        function terraform () {
            wine cmd /c "set PATH=%cd%\\vendor\\bin\\windows\\386;%PATH% && test.bat terraform $@"
        }
        export -f terraform

        run_test $@
    )
    result=$?
fi

exit $result
