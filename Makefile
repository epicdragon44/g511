initialize :
	@echo "Initializing..."
	find ./ -type f -iname "*.sh" -exec chmod +x {} \;
	./init.sh

install :
	@echo "Calling the 'install dependency' script..."
	./add-dep.sh

build :
	@echo "Building..."
	cd server && ./scripts/build.sh
	cd bot && ./scripts/build.sh

clean :
	@echo "Cleaning..."
	rm -rf ./server/_build
	rm -rf ./bot/_build

run :
	@echo "Running..."
	cd server && ./scripts/run.sh
	cd bot && ./scripts/run.sh

kill :
	@echo "Killing running scripts..."
	cd server && ./scripts/kill.sh
	cd bot && ./scripts/kill.sh

zip:
	@echo "Zipping..."
	rm -rf ./server/_build
	rm -rf ./bot/_build
	rm -f g511.zip
	zip -r g511.zip .
	cd server && ./scripts/build.sh
	cd bot && ./scripts/build.sh