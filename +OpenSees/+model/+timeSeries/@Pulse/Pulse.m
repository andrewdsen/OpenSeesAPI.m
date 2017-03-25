%This command is used to construct a TimeSeries object in which the load factor is some pulse 
% function of the time in the domain.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Pulse_TimeSeries
%
% tcl syntax:
% timeSeries Pulse $tag $tStart $tEnd $period <-width $pulseWidth> <-shift $shift> <-factor $cFactor>
%
% MATLAB syntax:
% Pulse(tag,tStart,tEnd,period)

classdef Pulse < OpenSees
    
    properties
        
        format = '% 0.5f';
        
        tag = [];           % time series tag
        tStart = [];        % starting time of non-zero load factor
        tEnd = [];          % ending time of non-zero load factor
        period = [];        % characteristic period of pulse
        pulseWidth = [];    % pulse width as a fraction of hte period (optional, default = 0.5)
        shift = [];         % phase shift in seconds (optional, default = 0.0)
        cFactor = [];       % the load amplification factor (optional, default = 1.0)
        
    end
    
    methods
        
        function obj = Pulse(tag,tStart,tEnd,period,varargin)
        
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'tStart');
            addRequired(p,'tEnd');
            addRequired(p,'period');
            addOptional(p,'width',obj.width);
            addOptional(p,'shift',obj.shift);
            addOptional(p,'cFactor',obj.cFactor);
            parse(p,tag,tStart,tEnd,period,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.tStart = tStart;
            obj.tEnd = tEnd;
            obj.period = period;
            
            % command line open
            obj.cmdLine = ['timeSeries Pulse ' num2str(obj.tag) ' ' ...
                           num2str(obj.tStart,obj.format) ' ' ...
                           num2str(obj.tEnd,obj.format) ' ' ...
                           num2str(obj.period,obj.format)];
            
            if any(ismember(p.UsingDefaults,'width')) == 0
                
                % store variable
                obj.pulseWidth = p.Results.pulseWidth;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-width ' num2str(obj.pulseWidth,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'shift')) == 0
                
                % store variable
                obj.shift = p.Results.shift;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-shift ' num2str(obj.shift,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'cFactor')) == 0
                
                % store variable
                obj.cFactor = p.Results.cFactor;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-factor ' num2str(obj.cFactor,obj.format)];
                
            end
            
        end
        
    end
    
end