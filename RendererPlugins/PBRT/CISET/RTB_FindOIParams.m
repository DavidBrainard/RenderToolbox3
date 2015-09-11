% Searches structure for parameters that are needed to construct oi
% object in CISET. These parameters are stored in the oiParams structure,
% since it is passed on throughout the pipeline.
%
%   [] = RTB_FindOIParams(objects,hints)
% 
% (c) TL

function [oiParams, success] = RTB_FindOIParams(internalParams,type)

checkFound = 0;
oiParams.lensType = type;
checkFound = checkFound + 1;

 % Check if we have camera class
 numClasses = size(internalParams,2);
 for i = 1:numClasses
             if(strcmp(internalParams(i).name,'specfile'))
                 oiParams.specFile = internalParams(i).value;
                 checkFound = checkFound + 1;
             end
             if(strcmp(internalParams(i).name,'filmdistance'))
                 oiParams.filmDistance = internalParams(i).value;
                 checkFound = checkFound + 1;
             end
             if(strcmp(internalParams(i).name,'aperture_diameter'))
                 oiParams.apertureDiameter = internalParams(i).value;
                 checkFound = checkFound + 1;
             end
             if(strcmp(internalParams(i).name,'filmdiag'))
                 oiParams.filmDiag = internalParams(i).value;
                 checkFound = checkFound + 1;
             end
   
 end %numClasses
 
% Make sure we got all the parameters we need
if (checkFound ~= 5)
    fprintf('WARNING: Parameters needed for OI were not all found.')
    success = 0;
else
    success = 1;
end

end