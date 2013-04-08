




class testOom2cppClass : public handle
{
public:
        Property prop1;
        Property prop2;
    
    
private:
        Property hiddenProp;
    

protected:
        Property protectedProp;
    

private:
        Property privateProp;
    
    
public:
        Event EventOne;
        Event EventTwo;
    
    
public:
self testOom2cppClass ()
{
            self.prop1 = 0;
        
}

        
sum addTwoProperties ( self)
{

            //! item is any Matlab variable
            //! group is a string or number for grouping related items
            //! mnemonic is a string or number to identifying the item
            
            sum = self.prop1 + self.prop2;
        
}

        
doSomeFlowControl ( self)
{

            if self.prop1 > 3
                switch self.prop2
                    case 1
                        
                    case 44444
                        
                end
                
            elseif self.prop1 < 30000
                self.prop2 = self.prop1;
            end
        
}

        
        
endKeywordAbuse( self,endLike,similarToend)
{

            self.prop1 = endLike;
            self.prop2 = similarToend;
            
            if endLike
                self.prop2 = 'end';
                self.prop1 = '"end"';
            end
            
            if (endLike) || similarToend+2 < endLike
                return
            end
        
}

    
    
public:
        
static shouldBeDeclaredStatic ()
{
            //! function shouldBeDeclaredStatic
        
}

        
static x shouldBeDeclaredStatic ( a)
{

            //! function x = shouldBeDeclaredStatic(a)
        
}

    
};
