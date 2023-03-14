# Create switch, install CS 3110 recommended base packages

opam switch create bocaml ocaml-base-compiler.4.14.0
eval $(opam env)
opam install -y utop odoc ounit2 qcheck bisect_ppx menhir ocaml-lsp-server ocamlformat ocamlformat-rpc

# Install setup packages

opam install -y user-setup
opam user-setup install

# Run install and build scripts for each project

cd server
chmod +x scripts/*.sh
./scripts/init.sh
./scripts/build.sh
cd ..

cd bot
chmod +x scripts/*.sh
./scripts/init.sh
./scripts/build.sh
cd ..