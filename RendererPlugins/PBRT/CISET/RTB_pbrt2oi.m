function oi = RTB_pbrt2oi(fname,oiParams,hints)
%Convert pbrt multispectral irradiance data into an ISET optical image
%
%   oi = pbrt2oi(fname,oiParams)
%
% fname is the output file produced by pbrt.
% oiParams is a structure that contains various pbrt parameters needed to
% create the oi. These parameters are passed down through the RTB pipeline.
% Unfortunately, right now it doesn't deal with multiple conditions.
%
% hints contains some more general parameters needed, specifically the
% image width and height.
%
% (c) Stanford VISTA Team 2012

if ieNotDefined('fname'), error('File name required.'); end
if ieNotDefined('oiParams'), error('No oiParameters specified.'); end
if ieNotDefined('hints'), error('Image width/height not specified.'); end
%open file
fID = fopen(fname,'r','l');

%load size information
[A, cnt] = fscanf(fID,'%d %d %d\n',[3 1]); %#ok<NASGU>

% The FOV and lens information now comes from elsewhere.
%load lens and field of view and information
[FOV, cnt2] = fscanf(fID,'%f %f %f\n',[3 1]); %#ok<ASGLU,NASGU>

%Load the stored photons produced by AL's pbrt code
photons = fread(fID,prod(A),'double');

%A(2) = rows, A(1) = columns
photons = reshape(photons,A(2),A(1),A(3));
fclose(fID);

% Set the OI data
oi = oiCreate;
oi = initDefaultSpectrum(oi);

% Put the irradiance in
% Check about this 32nd, and wavelength and all that!
% For now, we always run at 400:10:700 really, but AL needed to add one
% more for something about the PBRT calculation.  Here we toss the last
% wavelength.
oi = oiSet(oi,'photons',single(photons(:,:,1:31)));

oi = oiSet(oi, 'photons', oiGet(oi,'photons') * 10^13);  %some normalization issues

fprintf('Using PBRT output file for creating oi.')

lens = oiParams.lensType;

fdiag = str2num(oiParams.filmDiag);
dist  = str2num(oiParams.filmDistance);
x     = hints.imageWidth; % xresolution
y     = hints.imageHeight; % yresolution
apertureDiameter = str2num(oiParams.apertureDiameter);

if strcmp(lens,'realisticDiffraction')
    oi = oiSet(oi,'optics name',oiParams.specFile);
    oi = oiSet(oi,'optics fnumber',dist/apertureDiameter);
    
elseif strcmp(lens,'PinholeLens') % TODO: What are the real names for this in PBRT?
    % Pinholes have no real aperture size.  So, we set the f-number
    % really big.
    oi = oiSet(oi,'optics name','pinhole');
    oi = oiSet(oi,'optics fnumber',999);
    
elseif strcmp(lens,'IdealLens') % TODO: What are the real names for this in PBRT?
    % This case is a diffraction limited lens but with an aperture of a
    % real size.
    oi = oiSet(oi,'optics name','diffraction limited');
    oi = oiSet(oi,'optics fnumber',dist/apertureDiameter);
    
else
    fprintf('Could not find lens type in hints! Setting arbitrary values.')
    % TODO: What sort of arbitrary values should go here?
    
end

oi = oiSet(oi,'optics focal length',dist*1e-3);

% Compute the horizontal field of view
d     = sqrt(x^2+y^2);  % Number of samples along the diagonal
fwidth= (fdiag/d)*x;    % Diagonal size by d gives us mm per step
% multiplying by x gives us the horizontal mm
% Calculate angle in degrees
fov = 2*atan2d(fwidth/2,dist);

% Store the horizontal field of view in degrees in the oi
oi = oiSet(oi,'fov', fov);


return
