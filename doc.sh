# Bot Docs

echo "Generating documentation for bot ..."

cd bot
ocamldoc -html -d ../docs/bot lib/*.mli > /dev/null 2>&1
cd ..

sleep 2

# Server Docs

echo "Generating documentation for server ..."

cd server
ocamlfind ocamldoc -package cohttp,cohttp-lwt,lwt,rock,stdlib,uri,yojson -I _build -html -d ../docs/server lib/*.mli > /dev/null 2>&1
cd ..

sleep 2

# Open docs

open docs/index.html