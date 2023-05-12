# Count all non-empty lines of OCaml code
echo "Counting lines of code..."

# Count lines of code
count=$(find . -name "*.ml" -type f -print0 | xargs -0 cat | grep -v '^[[:space:]]*$' | wc -l)

# Output total count
echo "Total: $count lines of code"


