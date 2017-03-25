% This command is used to perform the analysis.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Analyze_Command
%
% tcl syntax:
% analyze $numIncr <$dt> <$dtMin $dtMax $Jd>
%
% MATLAB syntax:
% 

classdef analyze < OpenSees
    
    properties
        
        nSteps % number of analysis steps to perform
        dt     % time-step incremenet (required for transient or variable transient analysis)
        dtMin  % minimum number of time steps (required in variable transient analysis)
        dtMax  % maximum number of time steps (required in variable transient analysis)
        Jd     % number of iterations to perform at each step (required in variable transient 
               % analysis)...The variable transient analysis will change current time step if last 
               % analysis took more or less iterations than this to converge.
               
    end
    
    methods
        
        function obj = analyze(nSteps,dt,dtMin,dtMax,Jd)
            
            % store variables
            obj.nSteps = nSteps;
            
            % command line open
            obj.cmdLine = ['analyze ' num2str(obj.nSteps)];
            
            if nargin > 1
                
                % store variables
                obj.dt = dt;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.dt)];
                
                if nargin == 5

                    % store variables
                    obj.dtMin = dtMin;
                    obj.dtMax = dtMax;
                    obj.Jd = Jd;
                    
                    % command line add
                    obj.cmdLine = [obj.cmdLine ' ' ...
                                   num2str(obj.dtMin) ' ' ...
                                   num2str(obj.dtMax) ' ' ...
                                   num2str(obj.Jd)];
                               
                end
            end
            
        end
        
    end
    
end
            

                