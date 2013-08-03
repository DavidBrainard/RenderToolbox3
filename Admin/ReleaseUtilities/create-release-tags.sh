# This script creates git tags for RenderToolbox3 releases and pushes them to GitHub.
#
# It will only work if you have permission to push to the RenderToolbox3 repositories.
#
# If you are making a RenderToolbox3 release, you should copy this script and edit it
# with values like your local  doxygen path, and the version RenderToolbox3 that you
# are releasing.
#
# If nothing else, this script should document how to do a RenderToolbox3 release.
#

# edit these to match your local system
RTB_VERSION="v1.0"
RTB_REPO="git@github.com:DavidBrainard/RenderToolbox3.git"
RTB_WIKI="git@github.com:DavidBrainard/RenderToolbox3.wiki.git"
DOXYGEN="/Applications/Doxygen.app/Contents/Resources/doxygen" 
WORKING_FOLDER="/Users/ben/RenderToolbox3-release-temp"

mkdir $WORKING_FOLDER

### make a tag for the RenderToolbox3 master branch
echo
echo "Tagging RenderToolbox3 $RTB_VERSION"
echo

cd $WORKING_FOLDER
git clone $RTB_REPO
cd RenderToolbox3
git pull
git checkout master
git tag --force -a $RTB_VERSION -m "tag for RenderToolbox3 version $RTB_VERSION"
git push origin
git push origin --tags --force

### generate fresh doxygen documentation based on master branch, stored in gh-pages branch
echo
echo "Regenerating Doxygen docs"
echo

cd $WORKING_FOLDER
cp -r RenderToolbox3 RenderToolbox3-gh-pages
cd RenderToolbox3-gh-pages
git checkout gh-pages
git pull
cp RenderToolbox3Doxyfile RenderToolbox3Doxyfile-temp
echo "PROJECT_NUMBER=$RTB_VERSION" >> RenderToolbox3Doxyfile-temp
git rm -r docs
$DOXYGEN RenderToolbox3Doxyfile-temp
rm RenderToolbox3Doxyfile-temp

### make a tag for the new docs in the gh-pages branch
echo
echo "Tagging RenderToolbox3 $RTB_VERSION-docs"
echo

cd $WORKING_FOLDER/RenderToolbox3-gh-pages
git add .
git commit -m "fresh docs for RenderToolbox3 version $RTB_VERSION"
git tag --force  -a $RTB_VERSION-docs -m "tag for RenderToolbox3 version $RTB_VERSION-docs"
git push origin
git push origin --tags --force

### make a tag for the RenderToolbox3 wiki
echo
echo "Tagging RenderToolbox3 $RTB_VERSION-wiki"
echo

cd $WORKING_FOLDER
git clone $RTB_WIKI RenderToolbox3-wiki
cd RenderToolbox3-wiki
git tag --force -a $RTB_VERSION-wiki -m "tag for RenderToolbox3 version $RTB_VERSION-wiki"
git push origin
git push origin --tags --force
