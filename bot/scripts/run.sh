echo "Now running (on port 9001) in Silent Mode..."
dune exec ./_build/default/bin/main.exe -- -p 9001 -d > /dev/null 2>&1 &