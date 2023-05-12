# Bot Docs

echo "Generating documentation for bot ..."

cd bot
ocamldoc -html -d ../docs/bot lib/*.mli
cd ..

sleep 2

# Server Docs

echo "Generating documentation for server ..."

cd server
ocamlfind ocamldoc -package cohttp,cohttp-lwt,lwt,rock,stdlib,uri,yojson -I _build -html -d ../docs/server lib/*.mli
cd ..

sleep 2

# Open docs

open docs/index.html