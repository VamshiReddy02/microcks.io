#!/bin/bash

# Define colors for output
Red="\033[0;31m"
Green="\033[0;32m"
Color_Off="\033[0m"

echo -e "$Green Deploying updates to GitHub...$Color_Off"

# Get commit message from user or use a default message
if [ "$1" ]; then
  msg="$1"
else
  msg="Publishing site $(date)"
fi

# Get version tag from user input or prompt for one
if [ "$2" ]; then
  version="$2"
else
  read -p "$(echo -e $Red"Enter Tag Version: "$Color_Off)" version
fi

# Ensure we are on the correct branch
echo -e "$Green Switching to gh-pages branch...$Color_Off"
cd public
git checkout master  # Ensure we are on the correct branch

# Remove all old files from the repo
echo -e "$Green Removing outdated content from public repo...$Color_Off"
git rm -rf .

# Go back to the root project directory
cd ..

# Update version files
echo "$version" > version.txt
echo "$(date +'%a, %Y-%m-%d %T')" > buildDate.txt

# Build the site
export HUGO_ENV=production
echo -e "$Green Building the site...$Color_Off"
hugo --environment production --minify

# Commit and push changes to the public repository
cd public
git add --all
git commit -m "$msg"
git push origin master  # Push cleaned and updated content

# Go back to the main repo and tag the release
cd ..
git add version.txt buildDate.txt
git commit -m "$msg"
git tag "v$version"
git push origin master --tags

echo -e "$Green Deployment completed successfully!$Color_Off"
