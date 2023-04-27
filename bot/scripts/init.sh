# Install System Dependency OpenSSL

if [ "$(uname)" == "Darwin" ]; then
    brew install openssl     
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo apt-get install libssl-dev
fi

# Install dependencies

opam install -y telegraml
opam install -y dotenv

opam install -y cohttp

opam install -y cohttp-lwt-unix

opam install -y yojson

opam install -y ppx_lwt
