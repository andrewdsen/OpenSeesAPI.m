% This command is used to construct an AMD degree-of-freedom numbering object to provide the mapping
% between the degrees-of-freedom at the nodes and the equation numbers. An AMD numberer uses the 
% approximate minimum degree scheme to order the matrix equations. 
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/AMD_Numberer
%
% tcl syntax:
% numberer AMD

classdef AMD < OpenSees
    
    methods
        
        function obj = AMD()
            
            obj.cmdLine = 'numberer AMD';
            
        end
        
    end
    
end