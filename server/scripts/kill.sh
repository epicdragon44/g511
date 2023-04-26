echo "Terminating processes on port 9000..."

lsof -t -i tcp:9000 | xargs kill 