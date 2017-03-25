classdef work_point < handle
   
    properties (Access = public)
        
        node = [];  % work point nodes
    
    end
        
    properties (Access = private)
        
        db = [];    % database object
        
    end
    
    methods
       
        function obj = work_point(db, x, y, z)
           
            db.x_grid = x;
            db.y_grid = y;
            db.z_grid = z;
            for ii = 1:length(z)
                for jj = 1:length(x)
                    for kk = 1:length(y)
                        
                        tag = str2double(['1' num2str(ii, '%02g') num2str(jj, '%02g') num2str(kk-1, '%02g') '000']);
                        obj.node = vertcat(obj.node, OpenSees.model.node(tag, x(jj), y(kk), z(ii)));
                        
                    end
                end
            end
            db.addNode(obj.node);            
            
        end
        
    end
    
end