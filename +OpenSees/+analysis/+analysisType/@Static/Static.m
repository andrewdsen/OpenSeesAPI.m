% This command is used to construct the Analysis object, which defines what type of analysis is to 
% be performed. This analysis type is Static and is used for static analysis.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Analysis_Command
%
% tcl syntax:
% analysis Static

classdef Static < OpenSees
    
    methods
        
        function obj = Static()
            
            obj.cmdLine = 'analysis Static';
            
        end
        
    end
    
end