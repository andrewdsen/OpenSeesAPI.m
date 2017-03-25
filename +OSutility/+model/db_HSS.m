classdef db_HSS < handle
    
    properties
        
    end
    
    methods (Static)
        
        function obj = db_HSS()
            
            obj = readtable('HSS_meta.csv', 'ReadRowNames', true);
            
        end
        
    end
    
end