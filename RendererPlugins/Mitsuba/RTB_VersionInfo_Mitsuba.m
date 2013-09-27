info.PBRTPreferences = getpref('PBRT');
info.MitsubaPreferences = getpref('Mitsuba');

% PBRT executable date stamp
try
    info.PBRTDirInfo = dir(getpref('PBRT', 'executable'));
catch err
    info.PBRTDirInfo = err;
end

% Mitsuba executable date stamp
try
    mitsuba = fullfile( ...
        getpref('Mitsuba', 'app'), ...
        getpref('Mitsuba', 'executable'));
    info.MitsubaDirInfo = dir(mitsuba);
catch err
    info.MitsubaDirInfo = err;
end
