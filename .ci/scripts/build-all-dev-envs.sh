#!/usr/bin/env sh
PROJECT_FLAKES_DIR="project-flakes"

# Print lines of this script as they're executed, and exit on any failure.
set -ex

# Loop through each sub-directory in 'project-flakes'
for project in "$PROJECT_FLAKES_DIR"/*/ ; do  
  # Remove the trailing '/'
  project=${project%*/}
  # Extract the project name
  project=${project##*/}
  # Echo the project name for logging
  echo "Running nix develop on project: $project"
  # Extract the git URL of the project. We often need the files of the
  # project locally in order to build the development shell:
  url=$(grep "^# ci.project-url:" "$PROJECT_FLAKES_DIR/$project/module.nix" | awk -F': ' '{print $2}')
  # Extract the CI test command of the project. We'll use this to check
  # that the development environment built successfully.
  cmd=$(grep "^# ci.test-command:" "$PROJECT_FLAKES_DIR/$project/module.nix" | awk -F': ' '{print $2}')
  echo "Cloning repo: $url"
  # Clone the project to a directory with the same name.
  git clone --depth 1 -q "$url" "$project"
  # Enter the project directory.
  cd "$project"
  # Show the generated outputs of the flake.
  nix flake show ..
  # Attempt to build and enter the development environment,
  # then immediately exit the built shell.
  nix develop --impure ..#"$project" -c "true"
  # Leave the project directory.
  cd ..
  # Delete the project directory.
  rm -rf "$project"
done