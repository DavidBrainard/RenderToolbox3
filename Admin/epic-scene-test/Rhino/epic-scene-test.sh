# update RenderToolbox3
echo
echo "Updating RenderToolbox3"
echo

cd /home2/brainard/toolboxes/RenderToolbox3/
git pull

# clean up from any previous epic scene test
echo
echo "Cleaning Up from Previous Tests"
echo

cd /home2/brainard/render-toolbox-3/
rm -r epic-scene-test/temp
rm -r epic-scene-test/data
rm -r epic-scene-test/images

# invoke matlab on the head node to generate fresh scene files
#  head node supports OpenGL, required by Mitsuba Collada importer
echo
echo "Generating New Renderer-native Scene Files"
echo

CMDS="\
RenderToolbox3ConfigurationBrainard;\
cd('epic-scene-test');\
GenerateEpicSceneTestFiles;\
exit;"
matlab -nodesktop -nosplash -r "$CMDS"

# invoke matlab on workder nodes to render the scene files
cd /home2/brainard/render-toolbox-3/epic-scene-test
parmgo RenderEpicSceneTestFiles 10
