echo "Now running Bot on port 9001..."
dune exec ./_build/default/bin/main.exe -- -p 9001 -d > /dev/null 2>&1 &