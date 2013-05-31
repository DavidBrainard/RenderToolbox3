% RenderToolbox3InstallationTest
%
% Initialize RTB3 after installation and then
% put it through some basic tests.  If this
% runs properly, you're off to the races.
%
% 5/30/13  ncp  Wrote.
% 5/31/13  dhb  Expanded and tweaked.  

function RenderToolbox3InstallationTest

    %% Parameters
    
    % This defines a user-writable directory.  RTB output
    % will by default go into the subdirectory render-toolbox
    % in here.
    %
    % You need to run the initialization block after this
    % is set.
    localUserPath = '/Volumes/Users1/Shared/Matlab/';
    
    % Paths to the renderers.  You need to run the 
    % initialization block after these are set.
    localMitsubaPath = '/Applications';
    localPBRTPath = '/usr/local/bin';

    % Initialize.  Run the initializationn block?
    % Only need to do this once after RTB installation,
    % or after changes to the paths above.
    initialize = true;
       
    % Set to true to generate the scenes locally
    generate = false;
 
    % Set to true to compare the locally-rendered to the reference scenes
    compare = true;
    
    % Make sure the following commands have been issued in this order.
    % Note that userpath is a general matlab command and that any program
    % that uses it will have its ouput dumped into that folder.
    if (initialize)
        userpath(localUserPath);
        InitializeRenderToolbox(true);
        setpref('Mitsuba', 'app', fullfile(localMitsubaPath, 'Mitsuba.app'));
        setpref('PBRT', 'executable', fullfile(ocalPBRTPath, 'pbrt'));
    end
 
    if (generate)
        TestAllExampleScenes('');
    end
 
    % After running the TestAllExamplesScenes command (above) I had 12 more
    % directories than what is currently included in the ReferenceData. This causes
    % the CompareAllExamplesScenes() function below to fail. Instead of
    % modifying that function I moved those extra directories elsewhere.
    %
    % The 12 extra directories are:
    % MakeColorIllusion
    % MakeComplexScene
    % MakeInterrreflectionFIgure
    % MakeMaterialSphereBumps
    % MakeMaterialSpherePortable
    % MakeMatlabSimpleSphere
    % MakeRadianceTestFigure
    % MakeRGBPromotionFigure
    % MakeScaldingTestFigure
    % MakeSimpleSphereFigure
    % MakeSimpleSquareFigure
    % MakeTableSphereFigure
    
    if (compare)
        localRenderingsData = [localRenderings '/data'];
        % Make sure you download the reference data from: https://github.com/DavidBrainard/RenderToolbox3-ReferenceData.git
        % Location for reference data  
        referenceRenderingsData = '/Users/Shared/Matlab/RenderToolbox3Related/RenderToolbox3-ReferenceData/data';
        visualize = 1;
        matchInfo = CompareAllExampleScenes(localRenderingsData, referenceRenderingsData, '', visualize);
    end
 
end