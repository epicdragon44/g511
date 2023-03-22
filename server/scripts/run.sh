echo "Now running Server on port 9000..."
dune exec ./_build/default/bin/main.exe -- -p 9000 -d > /dev/null 2>&1 &