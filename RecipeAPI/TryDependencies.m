
clear
clc

configScript = 'RenderToolbox3ConfigurationTemplate';
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @MakeRecipeMontage, ...
    };
parentScene = 'SimpleSquare.dae';
conditionsFile = 'SimpleSquareConditions.txt';
mappingsFile = 'SimpleSquareMappings.txt';

hints.workingFolder = fullfile(GetUserFolder(), 'RecipeTest');
hints.renderer = 'Mitsuba';
hints.imageWidth = 50;
hints.imageHeight = 50;
hints.whichConditions = 1:4;
hints.isPlot = false;
hints.outputSubfolder = 'RecipeTest';

recipe = NewRecipe(configScript, executive, parentScene, ...
    conditionsFile, mappingsFile, hints);

recipe = AppendRecipeLog(recipe, 'Testing a new recipe');

%% Generate sceen files and pack up the recipe.
recipe = ExecuteRecipe(recipe, 1);
extras = {'usairforce-test-card.tga'};
fullZipFileName = fullfile(GetUserFolder(), 'withSceneFiles.zip');
[recipe, fullZipFileName] = PackUpRecipe(recipe, fullZipFileName, extras);

%% Un pack somewhere else and render the thing.
sillyRoot = fullfile(GetUserFolder(), 'Mender-Moolboxt');
hints.workingFolder = fullfile(sillyRoot, 'unpack-here');
hints.tempFolder = fullfile(sillyRoot, 'temp');
hints.outputDataFolder = fullfile(sillyRoot, 'data');
hints.outputImageFolder = fullfile(sillyRoot, 'images');
hints.resourcesFolder = fullfile(sillyRoot, 'resources');
recipe = UnpackRecipe(fullZipFileName, true, hints);

recipe = ExecuteRecipe(recipe);
