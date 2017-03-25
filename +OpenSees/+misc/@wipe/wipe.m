% This command is used to destroy all constructed objects, i.e. all components of the model, all 
% components of the analysis and all recorders.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Wipe_Command

classdef wipe < OpenSees
    
    methods
        
        function obj = wipe()
            
            obj.cmdLine = 'wipe';
            
        end
        
    end
    
end