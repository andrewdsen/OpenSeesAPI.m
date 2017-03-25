% This command is used to construct a Linear algorithm object which takes one iteration to solve the
% system of equations.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Linear_Algorithm
%
% tcl syntax:
% algorithm Linear <-initial> <-factorOnce>
%
% MATLAB syntax:
% Linear(<initial,factorOnce>)

classdef Linear < OpenSees
    
    properties
        
        initial = false;
        factorOnce = false;

    end
    
    methods
        
        function obj = Linear(initial,factorOnce)
            
            % command line open
            obj.cmdLine = 'algorithm Linear';
            
            if nargin > 0
                
                if initial == true

                    % store variables
                    obj.initial = initial;

                    % command line add
                    obj.cmdLine = [obj.cmdLine ' -initial'];

                end

                if factorOnce == true

                    % store variables
                    obj.factorOnce = factorOnce;

                    % command line add
                    obj.cmdLine = [obj.cmdLine ' -factorOnce'];

                end            
                
            end
            
        end
        
    end
    
end