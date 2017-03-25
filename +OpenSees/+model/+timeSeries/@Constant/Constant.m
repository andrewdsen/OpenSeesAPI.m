% This command is used to construct a TimeSeries object in which the load factor applied is linearly
% proportional to the time in the domain, i.e. ? = f(t) = cFactor*t
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Linear_TimeSeries
%
% tcl syntax:
% timeSeries Linear $tag <-factor $cFactor>
%
% MATLAB syntax:
% Linear(tag,<cFactor>)

classdef Constant < OpenSees
    
    properties
        
        format = '% 0.5f';
        
        tag     % time series tag
        cFactor % linear factor (optional)
        
    end
    
    methods
        
        function obj = Constant(tag,cFactor)
            
            % store variables
            obj.tag = tag;
            
            % command line open
            obj.cmdLine = ['timeSeries Constant ' num2str(obj.tag)];
            
            if nargin == 2
                
                % store variables
                obj.cFactor = cFactor;
                
                % command line add
                obj.cmdLine = [obj.cmdLine  ' -factor ' num2str(cFactor,obj.format)];
                
            end
            
        end
        
    end
    
end