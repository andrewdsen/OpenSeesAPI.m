classdef load_factor
    
properties
    
    % input
    load_comb   % string with load combination reference
    
    % output
    D    % load factor for dead load
    L    % load factor for live load
    
end

methods
    
    function obj = load_factor(load_comb)
        
        obj.load_comb = load_comb;
        switch load_comb
            case 'ASD'
                obj.D = 1;
                obj.L = 1;
            case 'ASCE 7-10'
                obj.D = 1;
                obj.L = 0.25;
            case 'FEMA P-695'
                obj.D = 1.05;
                obj.L = 0.25;
        end
        
    end
    
end

end