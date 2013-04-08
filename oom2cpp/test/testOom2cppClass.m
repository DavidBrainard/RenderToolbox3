%%% This text should be ignored.
%%% So should this text.

%%% And also, this text should be ignored.

classdef testOom2cppClass < handle
    properties
        prop1;
        prop2;
    end
    
    properties(Hidden)
        hiddenProp;
    end

    properties(Access = protected)
        protectedProp;
    end

    properties(Access=private)
        privateProp;
    end
    
    events
        EventOne;
        EventTwo;
    end
    
    methods
        function self = testOom2cppClass
            self.prop1 = 0;
        end
        
        function sum = addTwoProperties(self)
            % item is any Matlab variable
            % group is a string or number for grouping related items
            % mnemonic is a string or number to identifying the item
            
            sum = self.prop1 + self.prop2;
        end
        
        function doSomeFlowControl(self)
            if self.prop1 > 3
                switch self.prop2
                    case 1
                        
                    case 44444
                        
                end
                
            elseif self.prop1 < 30000
                self.prop2 = self.prop1;
            end
        end
        
        %%% This text should be ignored.
        function endKeywordAbuse(self, endLike, similarToend)
            self.prop1 = endLike;
            self.prop2 = similarToend;
            
            if endLike
                self.prop2 = 'end';
                self.prop1 = '"end"';
            end
            
            if (endLike) || similarToend+2 < endLike
                return
            end
        end
    end
    
    methods(Static)
        
        function shouldBeDeclaredStatic
            % function shouldBeDeclaredStatic
        end
        
        function x = shouldBeDeclaredStatic(a)
            % function x = shouldBeDeclaredStatic(a)
        end
    end
end