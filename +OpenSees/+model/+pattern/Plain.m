% This commnand allows the user to construct a LoadPattern object. Each plain load pattern is 
% associated with a TimeSeries object and can contain multiple NodalLoads, ElementalLoads and 
% SP_Constraint objects. The command to generate LoadPattern object contains in { } the commands to 
% generate all the loads and the single-point constraints in the pattern. To construct a load 
% pattern and populate it, the following command is used:
% 
% Ref: http://opensees.berkeley.edu/wiki/index.php/Plain_Pattern
%
% tcl syntax:
% pattern Plain $patternTag $tsTag <-fact $cFactor> {
% load...
% eleLoad...
% sp...
% ...
% }
%
% MATLAB syntax:
% Plain(patTag,ts,loads,<cFactor>)

classdef Plain < OpenSees
    
    properties
        
        format = '% 0.5f'; % string format
        
        patTag     % pattern tag
        ts         % time series object
        loads      % vertical array of load class(es)
        
    end
   
    methods
       
        function obj = Plain(patTag,ts,loads,cFactor)
            
            % store variables
            obj.patTag = patTag;
            obj.ts = ts;
            obj.loads = loads;
            
            % command line open
            obj.cmdLine = ['pattern Plain ' ...
                           num2str(obj.patTag) ' ' ...
                           num2str(obj.ts.tag)];
                       
            if nargin == 4
                
                % store variables
                obj.fact = cFactor;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -fact ' num2str(cFactor,obj.format)];
                
            end
            
            % command line add
            obj.cmdLine = [obj.cmdLine ' {\n'];
            for ii = 1:size(obj.loads,1)
                
                obj.cmdLine = [obj.cmdLine '\t' obj.loads(ii).cmdLine '\n'];
                
            end
            
            % command line close
            obj.cmdLine = [obj.cmdLine '}'];
            
        end
        
    end
    
end