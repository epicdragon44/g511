# First, navigate to the directory of the sub-repo that the dependency is being added to
read -p "Enter the sub-repo to add the dependency to (either bot or server):" usrdirectory
cd $usrdirectory

# Then, ask the user for the name of the OPAM dependency
read -p "Enter the name of the OPAM dependency:" usrdep

# Then, install the dependency
opam install -y $usrdep

# Then, add the dependency to the init.sh script
filename="scripts/init.sh"
# Check if the file exists or not
if [ -f $filename ]; then
      # Check if the dependency is already in the file
      if grep -q $usrdep $filename; then
            echo "Dependency already in init.sh"
      else
            # If the dependency is not in the file, add it
            echo "opam install -y $usrdep" >> $filename
      fi
else
      echo "File does not exist"
fi

# Then, prompt the user to add the library to the relevant dune files.
echo "You're not quite finished! You still need to add the library to the relevant dune files."
echo "If you're adding the dependency to the bin sub-folder, add the name of the package to the libraries field of the dune file in the bin sub-folder. The same goes for the lib sub-folder"
echo "Once you're done, you'll need to run make build to build the project again."

echo "Script exiting..."