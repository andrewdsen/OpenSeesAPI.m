classdef multinode < handle
   
    properties (Access = public)
       
        node = [];  % array of nodes
        
    end
    
    properties (Access = private)
        
        db = [];    % database object
        
    end
    
    methods
       
        function obj = multinode(db, x, y, z)
           
            for ii = 1:length(z)
                for jj = 1:length(x)
                    for kk = 1:length(y)
                        
                        tag = db.get_node_tag(x(jj), y(kk), z(ii));
                        this_node = OpenSees.model.node(tag, x(jj), y(kk), z(ii));
                        db.addNode(this_node);
                        obj.node = vertcat(obj.node, this_node);
                                                
                    end
                end
            end
            
        end
        
    end
    
end