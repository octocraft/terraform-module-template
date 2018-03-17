#!/bin/bash
set -eu

# Check if Terraform is present
if ! tf_dir=$(command -v terraform); then
    echo 'error: terraform not found in $PATH'
    exit 2
fi

# Test with wine (if present)
((command -v 'wine' &> /dev/null) && ([ -z "${TFTEST_WINE+x}" ] || $TFTEST_WINE)) && test_wine=true || test_wine=false

# outputs.diff
[ -f "outputs.diff" ] && ([ -z "${TFTEST_DIFFOUTPUT+x}" ] || $TFTEST_DIFFOUTPUT) && diff_output=true || diff_output=false

function clean () {
    rm -rf .terraform
    rm -f terraform.tfstate
    rm -f terraform.tfstate.backup
}

# Test function
function exec_tf () {

    set +e
    (
        set -e
        terraform init -input=false -no-color > /dev/null
        terraform get > /dev/null
        set +e
        terraform apply -input=false -auto-approve -no-color
        res=$?
        terraform destroy -force -no-color > /dev/null
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
        outputs=$(echo "$output" | grep -A $numlines "^Outputs:$" | grep -e '^[^ =]* = ')
        set -e

        if [ ! -z "${1+x}" ] && [ -f "$1" ]; then
            difffile="$1"
        elif $diff_output && [ -f "outputs.diff" ]; then
            difffile="outputs.diff"
        else
            difffile=""
        fi

        output="$outputs"

        if [ ! -z "$difffile" ]; then

            set +e
            [ "$outputs" = "$(< "$difffile")" ]
            result=$?
            set -e

            if [ "$result" -ne 0 ]; then
                output=$(printf "%s\n%s" "output does not match with '$difffile':" "$outputs")
            fi
        fi
    fi

    printf "%s\n" "$output"

    return $result
}

# Parse command line arguments
if [ "$#" -ge 2 ]; then
    diff_unix="$1"
    diff_wine="$2"
elif [ "$#" -ge 1 ]; then
    diff_unix="$1"
    diff_wine="$1"
else
    diff_unix=""
    diff_wine=""
fi

# Run Test
clean
run_test $diff_unix
result=$?
if [ "$result" -ne 0 ]; then exit $result; fi

if $test_wine; then
    printf "\n"
    (
        function terraform () {
            wine cmd /c "set PATH=${tf_dir%current*}/windows/386;%PATH% && terraform $@"
        }
        export -f terraform

        run_test $diff_wine
    )
    result=$?
fi
clean
exit $result
