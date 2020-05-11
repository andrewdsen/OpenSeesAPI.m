classdef rigidDiaphragm < OpenSees
    
    properties
        
        perpDirn;       % direction perpendicular to the rigid plane
        masterNode;     % retained, or master node
        slaveNode;      % constrained, or slave node(s)
                    
    end
    
    methods
        
        function obj = rigidDiaphragm(perpDirn, masterNode, slaveNode);
           
            % store variables
            obj.perpDirn = perpDirn;
            obj.masterNode = masterNode;
            obj.slaveNode = slaveNode;
            
            % command line open
            obj.cmdLine = ['rigidDiaphragm ' ...
                           num2str(obj.perpDirn) ' ' ...
                           num2str(obj.masterNode.tag) ' ' ...
                           num2str([obj.slaveNode.tag])];
            
        end
        
    end
    
end