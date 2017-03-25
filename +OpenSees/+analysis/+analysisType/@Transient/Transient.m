% This command is used to construct the Analysis object, which defines what type of analysis is to 
% be performed. This analysis type is Transient and is used for transient analysis with constant
% time step.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Analysis_Command
%
% tcl syntax:
% analysis Transient

classdef Transient < OpenSees
    
    methods
        
        function obj = Transient()
            
            obj.cmdLine = 'analysis Transient';
            
        end
        
    end
    
end