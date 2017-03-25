% This command is used to construct a Plain constraint handler. A plain constraint handler can only 
% enforce homogeneous single point constraints (fix command) and multi-point constraints constructed
% where the constraint matrix is equal to the identity (equalDOF command).
% 
% Ref: http://opensees.berkeley.edu/wiki/index.php/Plain_Constraints
%
% tcl syntax:
% constraints Plain

classdef Plain < OpenSees
    
    methods
        
        function obj = Plain()
            
            obj.cmdLine = 'constraints Plain';
            
        end
        
    end
    
end