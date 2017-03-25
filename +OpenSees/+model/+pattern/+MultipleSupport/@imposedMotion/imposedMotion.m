classdef imposedMotion < OpenSees
   
    properties
        
        node = [];          % node on which constraint is to be placed
        dirn = [];          % dof of enforced responsed. Valid range is from 1 through ndf at node
        gMotionTag = [];    % pre-defined GroundMotion object tag
        
    end
    
    methods
       
        function obj = imposedMotion(node,dirn,gMotionTag)
           
            % store variables
            obj.node = node;
            obj.dirn = dirn;
            obj.gMotionTag = gMotionTag;
            
            % command line open
            obj.cmdLine = ['imposedMotion ' num2str(obj.node.tag) ' ' ...
                           num2str(obj.dirn) ' ' ...
                           num2str(gMotionTag)];
            
        end
        
    end
    
end