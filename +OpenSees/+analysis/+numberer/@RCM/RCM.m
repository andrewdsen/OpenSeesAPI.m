% This command is used to construct an RCM degree-of-freedom numbering object to provide the mapping
% between the degrees-of-freedom at the nodes and the equation numbers. An RCM numberer uses the 
% reverse Cuthill-McKee scheme to order the matrix equations.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/RCM_Numberer
%
% tcl syntax:
% numberer RCM

classdef RCM < OpenSees
    
    methods
        
        function obj = RCM()
            
            obj.cmdLine = 'numberer RCM';
            
        end
        
    end
    
end