initialize :
	@echo "Initializing..."
	find ./ -type f -iname "*.sh" -exec chmod +x {} \;
	./init.sh

clean :
	@echo "Cleaning..."
	rm -rf ./server/_build
	rm -rf ./bot/_build

deploy :
	@echo "Deploying..."
	rm -rf ./server/_build
	rm -rf ./bot/_build
	./deploy.sh

kill :
	@echo "Killing deployed environment..."
	cd server && ./scripts/kill.sh
	cd bot && ./scripts/kill.sh

build :
	@echo "Building..."
	cd server && ./scripts/build.sh
	cd bot && ./scripts/build.sh

dev :
	@echo "Starting dev environment..."
	cd server && ./scripts/build.sh && ./scripts/run-dev.sh
	cd bot && ./scripts/build.sh && ./scripts/run-dev.sh


