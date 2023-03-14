echo "Now running (on port 9000) in Silent Mode..."
dune exec ./_build/default/bin/main.exe -- -p 9000 -d > /dev/null 2>&1 &