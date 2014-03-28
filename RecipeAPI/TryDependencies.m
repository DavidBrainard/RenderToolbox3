
clear
clc

configScript = 'PBRTOpticsConfigurationTemplate';
executive = @RenderRecipe;
parentScene = 'SimpleSquare.dae';
conditionsFile = 'SimpleSquareConditions.txt';
mappingsFile = 'SimpleSquareMappings.txt';

hints.workingFolder = fullfile(GetUserFolder(), 'RecipeTest');
hints.renderer = 'Mitsuba';
hints.imageWidth = 50;
hints.imageHeight = 50;
hints.whichConditions = 1:4;
hints.isPlot = false;
hints.outputSubfolder = 'dependenciesTest';

recipe = NewRecipe(configScript, executive, parentScene, ...
    conditionsFile, mappingsFile, hints);

recipe = AppendRecipeLog(recipe, 'Testing a new recipe');

%% Stick some outputs in the recipe.
recipe = ConfigureForRecipe(recipe);
recipe = MakeRecipeSceneFiles(recipe);
recipe = MakeRecipeRenderings(recipe);
recipe = MakeRecipeMontage(recipe);

%% Pack up the whole thing.
extras = {'usairforce-test-card.tga'};
fullZipFileName = fullfile(GetUserFolder(), 'fullPack.zip');
[recipe, fullZipFileName] = PackUpRecipe(recipe, fullZipFileName, extras);

%% Pack up a cleaned version.
recipe = CleanRecipe(recipe);
cleanZipFileName = fullfile(GetUserFolder(), 'cleanPack.zip');
[recipe, cleanZipFileName] = PackUpRecipe(recipe, cleanZipFileName);

%% Unpack the whole thing and try to re-render without making scene files.
sillyRoot = fullfile(GetUserFolder(), 'Mender-Moolboxt');
hints.workingFolder = fullfile(sillyRoot, 'unpack-here');
hints.tempFolder = fullfile(sillyRoot, 'temp');
hints.outputDataFolder = fullfile(sillyRoot, 'data');
hints.outputImageFolder = fullfile(sillyRoot, 'images');
hints.resourcesFolder = fullfile(sillyRoot, 'resources');
recipe = UnpackRecipe(fullZipFileName, true, hints);

recipe = MakeRecipeRenderings(recipe);