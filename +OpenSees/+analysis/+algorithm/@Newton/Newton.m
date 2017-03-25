% This command is used to construct a Linear algorithm object which takes one iteration to solve the
% system of equations.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Linear_Algorithm
%
% tcl syntax:
% algorithm Linear <-initial> <-factorOnce>
%
% MATLAB syntax:
% Newton(<initial,initialThenCurrent>)

classdef Newton < OpenSees
    
    properties
        
        initial = false;            % optional falg to use initial stiffness iterations
        initialThenCurrent = false; % optional flag to indicat to use initial stiffness on first
                                    % step, then use current stiffness for subsequent steps

    end
    
    methods
        
        function obj = Newton(initial,initialThenCurrent)
            
            % command line open
            obj.cmdLine = 'algorithm Newton';
            
            if nargin > 0
                
                if initial == true && initialThenCurrent == true
                    
                    error(['invalid input:\n' ...
                           '\tboth ''initial'' and ''initialThenCurrent'' cannot be true'],...
                           class(initial),class(initialThenCurrent));
                      
                end
                
                if initial == true

                    % store variables
                    obj.initial = initial;

                    % command line add
                    obj.cmdLine = [obj.cmdLine ' -initial'];

                end

                if initialThenCurrent == true

                    % store variables
                    obj.initialThenCurrent = initialThenCurrent;

                    % command line add
                    obj.cmdLine = [obj.cmdLine ' -initialThenCurrent'];

                end            
                
            end
            
        end
        
    end
    
end