% Find node using X and Y coordinates.

classdef nodeWithXY < handle
    
    properties
        
        % input
        db = [];        % database instance
        coords = [];    % nodal coordinates in form of [xi yi xj yj]
        
        % output
        iNode = [];     % node i object
        jNode = [];     % node j object
        
    end
    
    methods
        
        function obj = nodeWithXY(db,coords)
            
            % store variables
            obj.db = db;
            obj.coords = coords;
            
            obj.iNode = findobj(db.node,'x',coords(1),'y',coords(2));
            obj.jNode = findobj(db.node,'x',coords(3),'y',coords(4));
            
        end
        
    end
    
end