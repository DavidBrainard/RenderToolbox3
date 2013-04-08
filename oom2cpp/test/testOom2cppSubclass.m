%%% This text should be ignored.
%%% So should this text.
classdef testOom2cppSubclass < testOom2cppClass & someOtherClass
    
    %%% This text should be ignored.
    properties
        prop3;
    end
    
    events
        EventThree;
    end
    
    methods
        function self = testOom2cppSubclass
            %%% This text should be ignored.
            self. self@testOom2cppClass;
        end
    end
end