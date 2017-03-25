% This command is used to construct a multi-point constraint between nodes.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/EqualDOF_command
%
% tcl syntax:
% equalDOF $rNodeTag $cNodeTag $dof1 $dof2 ...
%
% MATLAB syntax:
% 

classdef equalDOF < OpenSees
    
    properties
        
        rNode   % retained, or master node (rNode)
        cNode   % constrained, or slave node (cNode)
        dof     % array with nodal dofs that are constrained at the cNode to be the same as
                % those at the rNode; valid range is 1 through ndf
                    
    end
    
    methods
        
        function obj = equalDOF(rNode,cNode,dof)
           
            % store variables
            obj.rNode = rNode;
            obj.cNode = cNode;
            obj.dof = dof;
            
            % command line open
            obj.cmdLine = ['equalDOF ' ...
                           num2str(obj.rNode.tag) ' ' ...
                           num2str(obj.cNode.tag) ' ' ...
                           num2str(obj.dof)];
            
        end
        
    end
    
end