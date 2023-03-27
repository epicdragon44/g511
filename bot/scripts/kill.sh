echo "Terminating processes on port 9001..."

lsof -t -i tcp:9001 | xargs kill 