classdef Path < OpenSees
   
    properties
       
        format = '%0.5f ';
        
        % required
        tag = [];   % unique tag among TimeSeries objects
        
        % optional
        dt = [];    % time interval between specified points
        values = [];    % load-factor values in a tcl list
        cFactor = [];   % a factor to multiply load factors by (default = 1.0)
        
    end
    
    methods
        
        function obj = Path(tag,varargin)
           
            p = inputParser;
            addRequired(p,'tag');
            addOptional(p,'dt',obj.dt);
            addOptional(p,'values',obj.values);
            addOptional(p,'cFactor',obj.cFactor);
            parse(p,tag,varargin{:});
            
            % store variables
            obj.tag = tag;
            
            % command line open
            obj.cmdLine = ['timeSeries Path ' num2str(obj.tag)];
            
            if any(ismember(p.UsingDefaults,'dt')) == 0
                
                % store variable
                obj.dt = p.Results.dt;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-dt ' num2str(obj.dt,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'values')) == 0
                
                % store variable
                obj.values = p.Results.values;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-values {' num2str(obj.values,obj.format) '}'];
                
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