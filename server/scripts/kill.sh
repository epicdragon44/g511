echo "Terminating processes on port 9000..."

if [ "$(uname)" == "Darwin" ]; then
    lsof -t -i tcp:9000 | xargs kill 
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo kill -9 $(sudo lsof -t -i:9000)
fi