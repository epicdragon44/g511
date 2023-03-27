echo "Terminating processes on port 9001..."

if [ "$(uname)" == "Darwin" ]; then
    lsof -t -i tcp:9001 | xargs kill 
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sudo kill -9 $(sudo lsof -t -i:9001)
fi