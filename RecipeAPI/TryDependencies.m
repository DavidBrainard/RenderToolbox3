
clear
clc

configScript = 'PBRTOpticsConfigurationTemplate';
executive = @RenderRecipe;
parentScene = 'SimpleSquare.dae';
conditionsFile = 'SimpleSquareConditions.txt';
mappingsFile = 'SimpleSquareMappings.txt';
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
fullZipFileName = fullfile(GetOutputPath('tempFolder', hints), 'fullPack.zip');
[recipe, fullZipFileName] = PackUpRecipe(recipe, fullZipFileName, extras);

%% Pack up a cleaned version.
recipe = CleanRecipe(recipe);
cleanZipFileName = fullfile(GetOutputPath('tempFolder', hints), 'cleanPack.zip');
[recipe, cleanZipFileName] = PackUpRecipe(recipe, cleanZipFileName);

%% Unpack the whole thing and try to re-render without making scene files.
sillyRoot = '/Users/ben/Documents/MATLAB/frender-foolbox';
hints.tempFolder = fullfile(sillyRoot, 'temp');
hints.outputDataFolder = fullfile(sillyRoot, 'data');
hints.outputImageFolder = fullfile(sillyRoot, 'images');
hints.resourcesFolder = fullfile(sillyRoot, 'resources');
recipe = UnpackRecipe(fullZipFileName, true, hints);

recipe.input.hints = hints;
recipe = MakeRecipeRenderings(recipe);