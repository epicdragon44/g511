# Custom scripts for setup only. Uses bash scripts at the root level to encapsulate complex logic.

initialize :
	@echo "Initializing..."
	find ./ -type f -iname "*.sh" -exec chmod +x {} \;
	./init.sh

install :
	./add-dep.sh

# Custom scripts for development. Uses bash scripts located within scripts/ in each sub-repo for more granular control.

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

# Tests all the code and outputs the results to the console.

test:
	@echo "Testing..."
	cd server && dune exec test/main.exe

# Commands to help with submission.

doc:
	./doc.sh

loc:
	./loc.sh

zip:
	@echo "Zipping..."
	rm -rf ./server/_build
	rm -rf ./bot/_build
	rm -f g511.zip
	zip -r g511.zip .
	cd server && ./scripts/build.sh
	cd bot && ./scripts/build.sh

# Commands to help with maintaining a deployed version.

force-update:
	@echo "Force updating the local copy from main on origin..."
	git fetch --all
	git reset --hard origin/main