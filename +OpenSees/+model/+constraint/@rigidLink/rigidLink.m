% This command is used to construct a multi-point constraint between nodes.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/EqualDOF_command
%
% tcl syntax:
% equalDOF $rNodeTag $cNodeTag $dof1 $dof2 ...
%
% MATLAB syntax:
% 

classdef rigidLink < OpenSees
    
    properties
        
        type         % bar or beam
        masterNode   % retained, or master node (rNode)
        slaveNode    % constrained, or slave node (cNode)
                    
    end
    
    methods
        
        function obj = rigidLink(type,masterNode,slaveNode,dof)
           
            % store variables
            obj.type = type;
            obj.masterNode = masterNode;
            obj.slaveNode = slaveNode;
            
            % command line open
            obj.cmdLine = ['rigidLink ' ...
                           obj.type ' ' ...
                           num2str(obj.masterNode.tag) ' ' ...
                           num2str(obj.slaveNode.tag)];
            
        end
        
    end
    
end