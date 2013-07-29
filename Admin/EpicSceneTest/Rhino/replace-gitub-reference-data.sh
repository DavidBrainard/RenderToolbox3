# This script adds RenderToolbox3 reference data to the 
# RenderToolbox3-ReferenceData repository at GitHub, replacing all the data
# currently in that repository.  The reason to replace data instead of 
# committing changes normally is that the repository contains lots of large
# binary files.  Normal commits would cause the repository to grow very large.
#
# This script will only work if you have permission to push to
# RenderToolbox3-ReferenceData.
#
# If you are making a RenderToolbox3 release, you should copy this script
# and edit it with values like the  version of RenderToolbox3 that you 
# are releasing and the paths to the RenderToolbox3 temp, data, and image 
# output folders.
#
# If nothing else, this script should document how to push fresh renderings
# to the RenderToolbox3-ReferenceData repository.
#

# edit these to match your local system
RTB_VERSION="v1.0"
RTB_REF_DATA="git@github.com:DavidBrainard/RenderToolbox3-ReferenceData.git"
RTB_TEMP="/home2/brainard/render-toolbox-3/epic-scene-test/temp"
RTB_DATA="/home2/brainard/render-toolbox-3/epic-scene-test/data"
RTB_IMAGES="/home2/brainard/render-toolbox-3/epic-scene-test/images"
WORKING_FOLDER="/home2/brainard/render-toolbox-3/epic-scene-test"

echo
echo "Remove local reference-data repository"
echo

# remove any old local reference data repo
cd $WORKING_FOLDER
rm -rf RenderToolbox3-ReferenceData

echo
echo "Create new reference-data repository"
echo

# make new local git repo to hold reference data
mkdir RenderToolbox3-ReferenceData
cd RenderToolbox3-ReferenceData
touch README.md
git init
git add README.md
git commit -m "new repo for RenderToolbox3 $RTB_VERSION reference data"
mv $RTB_TEMP .
mv $RTB_DATA .
mv $RTB_IMAGES .
git add .
git commit -m "import RenderToolbox3 reference data for $RTB_VERSION"

echo
echo "Tagging RenderToolbox3-ReferenceData $RTB_VERSION-reference-data"
echo

git tag -a $RTB_VERSION-reference-data -m "tag for RenderToolbox3 version $RTB_VERSION-reference-data"

echo
echo "push new reference data repository to $RTB_REF_DATA"
echo

# push the new repository to GitHub, replacing the old repository
git remote add origin $RTB_REF_DATA 
git push --tags --set-upstream --force origin master

