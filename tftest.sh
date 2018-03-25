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

    verify="$1"

    set +e
    (
        set -e
        terraform init -input=false -no-color > /dev/null
        terraform get > /dev/null
        terraform apply -input=false -auto-approve -no-color
        $verify
        terraform destroy -force -no-color > /dev/null
    )
    result=$?
    set -e

    return $result
}

function run_test () {

    difffile="outputs.diff"; [ -f "$difffile" ] || difffile=""
    verify="./verify.sh";    [ -f "$verify" ]   || verify=""

    if [ ! -z "$1" ]; then
        if [ ! -f "$1" ]; then
            printf "file '%s' not found\n" "$1" 1>&2
            return 2
        fi

        difffile="$1"
    fi

    if [ ! -z "$2" ]; then
        if ! command -v "$2" &> /dev/null; then
            printf "command '%s' not found\n" "$2" 1>&2
            return 2
        fi

        verify="$2"
    fi

    # run test
    set +e
        output=$(exec_tf "$verify" 2>&1)
        result=$?
    set -e

    if [ "$result" -eq 0 ]; then

        set +e
        outputs=$(
            out=false
            while IFS= read -r line; do
                if $out && [ -n "$line" ]; then echo "$line"; fi;
                if [ "$line" = "Outputs:" ]; then out=true; fi
            done < <(printf '%s\n' "$output")
        )
        set -e

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
if [ "$#" -ge 3 ]; then
    verify="$3"
else
    verify=""
fi

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
run_test "$diff_unix" "$verify"
result=$?
if [ "$result" -ne 0 ]; then exit $result; fi

if $test_wine; then
    printf "\n"
    (
        function terraform () {
            wine cmd /c "set PATH=${tf_dir%current*}/windows/386;%PATH% && terraform $@"
        }
        export -f terraform

        run_test "$diff_wine" "$verify"
    )
    result=$?
fi
clean
exit $result
