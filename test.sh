# Build and run server and bot

make kill > /dev/null 2>&1
make build > /dev/null 2>&1
make run > /dev/null 2>&1

echo "Preparing to run tests..."
echo ""
sleep 3

# Run tests

declare -i total_cases=0
declare -i total_failures=0

print_errors() {
    dir=$1
    cd $dir
    output=$(dune exec test/main.exe)
    cd ..

    sleep 1

    echo "$output" | awk '/=====/{flag=1; next} /-----/{flag=0} flag'
}

for dir in server bot
do
    cd $dir
    output=$(dune exec test/main.exe)
    cd ..

    # Check if the output contains "OK"
    if echo "$output" | grep -q "OK"; then
        echo ""
        echo "$dir tests passed"
    else
        # Extract the Cases and Failures
        cases=$(echo "$output" | grep -o -E 'Cases: [0-9]+' | grep -o -E '[0-9]+')
        failures=$(echo "$output" | grep -o -E 'Failures: [0-9]+' | grep -o -E '[0-9]+')

        total_cases+=cases
        total_failures+=failures

        echo ""
        echo "$dir tests failed: $failures failures out of $cases cases"
    fi
done

echo ""

# If there were any failures, print the errors. Otherwise, print a success message.
if (( total_failures > 0 )); then
    echo "ERRORS IN SERVER =============================="
    print_errors server
    echo "ERRORS IN BOT ================================="
    print_errors bot
    echo "==============================================="
    echo ""
    echo "Total: $total_failures tests failed out of $total_cases total cases"
else
    echo ""
    echo "All tests passed!"
fi

# Kill server and bot

sleep 1

make kill > /dev/null 2>&1

