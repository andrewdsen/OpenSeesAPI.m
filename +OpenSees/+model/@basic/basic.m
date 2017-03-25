% This command is used to define spatial dimension of model and number of degrees-of-freedom at 
% nodes. Once issued additional commands are added to interpreter.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Model_command

classdef basic < OpenSees
    
    properties
        
        ndm % number of dimensions
        ndf % number of degrees of freedom
        
    end
    
    methods
        
        function obj = basic(ndm,ndf)
            
            % store variables
            obj.ndm = ndm;
            obj.ndf = ndf;
            
            % command line
            obj.cmdLine = ['model BasicBuilder -ndm ' num2str(obj.ndm) ' -ndf ' num2str(obj.ndf)];
            
        end
        
    end
    
end