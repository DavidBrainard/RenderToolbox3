clear;
clc;

stuff = cell(1,4);

parfor ii = 1:4
    
    %% Set up system dybamic library path.
    if ismac()
        % OS X
        libPathName = 'DYLD_LIBRARY_PATH';
        libPath = '';
        libPathLast = '';
        
        importer = '/Applications/Mitsuba.app/Contents/MacOS/mtsimport';
        
    else
        % Linux
        libPathName = 'LD_LIBRARY_PATH';
        libPath = [];
        libPathLast = 'matlab|MATLAB';
        
        importer = '/home2/brainard/bin/mtsimport';
    end
    
    originalLibPath = getenv(libPathName);
    if ischar(libPath)
        newLibPath = libPath;
    else
        newLibPath = originalLibPath;
    end
    
    setenv(libPathName, newLibPath);
    
    if ischar(libPathLast)
        newLibPath = DemoteEnvPathEntries(libPathName, libPathLast);
    end
    
    %% Convert a Collada scene to a Mistuba scene.
    
    err = [];
    status = [];
    resultString = [];
    try
        colladaFile = 'CoordinatesTest-CoordinatesTest-001-7bit-reduced.dae';
        outputFile = sprintf('CoordinatesTest-%d.xml', ii);
        width = 320;
        height = 240;
        filmType = 'hdrfilm';
        
        importCommand = sprintf('%s -r %dx%d -l %s %s %s', ...
            importer, ...
            width, height, ...
            filmType, ...
            colladaFile, ...
            outputFile);
        
        % mtsimport executable needs X11 Server / OpenGL Context
        disp(importCommand)
        [status, resultString] = unix(importCommand)
        
    catch e
        err = e;
    end
    
    setenv(libPathName, originalLibPath);
    
    if ~isempty(err)
        rethrow(err)
    end
    
    thing = [];
    thing.err = err;
    thing.status = status;
    thing.resultString = resultString;
    stuff{ii} = thing;
end

save('MitsubaConvert.mat')