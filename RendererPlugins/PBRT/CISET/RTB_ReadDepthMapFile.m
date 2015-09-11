function A3 = RTB_ReadDepthMapFile(depthMapFile, imageSize)
% Reads in a .dat file with the depth data output of the PBRT-spectral
% renderer.
% 
%  A3 = RTB_ReadDepthMapFile(depthMapFile)
% 
% 
% Inputs: 
% depthMapFile: string of the .dat depth map file
% 
% Return values:
%   A3: This function returns the UNNORMALIZED 2D depth map image. 
%   This function also writes, depthMapView.tif, the resulting NORMALIZED depth map 
%   preview image. For the normalized depth map preview image, the value 0 corresponds to 
%   the lower limit and the value 1 corresponds to the upper limit of the unnormalized range.  
% 
% Example: 
%  depthMap = s3dReaddepthMapFile('depthmap.zbf');
% 
% (c) Stanford VISTA Team

%%

% There should be error checking here.

fid = fopen(depthMapFile, 'r', 'l');

%A = fread(fid, 'float32');
A = fread(fid, 'double');

% if size is not defined, assume a square
if (ieNotDefined('imageSize'))
    imageSize = [round(sqrt(size(A,1))) round(sqrt(size(A,1)))]
end

A2 = A(1:imageSize(1)*imageSize(2));

%reshape data
A3 = reshape(A2, [imageSize(2) imageSize(1)])';

return

