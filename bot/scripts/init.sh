# Install System Dependency OpenSSL

if [ "$(uname)" == "Darwin" ]; then
    brew install openssl     
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo apt-get install libssl-dev
fi

# Install TelegraML as a dependency for the Telegram Chatbot

opam install -y telegraml

# Install dot env to read from .env file

opam install -y dotenv