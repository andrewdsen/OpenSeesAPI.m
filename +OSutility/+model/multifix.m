classdef multifix < handle
   
    properties (Access = private)
        
        db = [];        % database object
        node = [];      % array of nodes
        fixity = [];    % specified fixity applied to ALL nodes in array

    end
    
    methods
       
        function obj = multifix(db, node, fixity)
           
            for ii = 1:length(node)
                db.addFix( OpenSees.model.constraint.fix(node(ii), fixity) );    
            end
            
        end
        
    end
    
end