# Install Opium to serve the backend
opam install -y opium

# Install Curly to make API calls
opam install -y curly

# Install Jane Street's ppx_inline_test to make (much cleaner) inline tests
opam install -y ppx_inline_test

# Install dot env to read from .env file
opam install -y dotenv

# Install Cohttp for API requests
opam install -y cohttp-lwt-unix
opam install -y cohttp

# Install Yojson for JSON parsing
opam install -y yojson
