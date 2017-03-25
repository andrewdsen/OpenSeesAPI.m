% This command is used to construct the Analysis object, which defines what type of analysis is to 
% be performed. This analysis type is VariableTransient and is used for transient analysis with 
% variable time step.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Analysis_Command
%
% tcl syntax:
% analysis VariableTransient

classdef VariableTransient < OpenSees
    
    methods
        
        function obj = VariableTransient()
            
            obj.cmdLine = 'analysis VariableTransient';
            
        end
        
    end
    
end