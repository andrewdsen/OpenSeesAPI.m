% This command is used to construct a Plain degree-of-freedom numbering object to provide the 
% mapping between the degrees-of-freedom at the nodes and the equation numbers. A Plain numberer 
% just takes whatever order the domain gives it nodes and numbers them, this ordering is both 
% dependent on node numbering and size of the model.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Plain_Numberer
%
% tcl syntax:
% numberer Plain

classdef Plain < OpenSees
    
    methods
        
        function obj = Plain()
            
            obj.cmdLine = 'numberer Plain';
            
        end
        
    end
    
end