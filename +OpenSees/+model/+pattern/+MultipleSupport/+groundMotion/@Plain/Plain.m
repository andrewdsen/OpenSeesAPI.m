classdef Plain < OpenSees
   
    properties
        
        % required
        tag = [];   % unique tag among ground motions in load pattern
        
        % at least one of these is required
        accelTs = [];   % acceleation timeSeries object
        velTs = [];     % velocity timeSeries object
        dispTs = [];    % displacement timeSeries object
        
        % optional (not supported yet)
        integratorType = [];    % used to generate a numerical integrator (default TRAPEZOIDAL)
        cFactor = [];           % constant factor (default = 1.0)
        
    end
    
    methods
       
        function obj = Plain(tag,varargin)
        
            p = inputParser;
            addRequired(p,'tag');
            addOptional(p,'accelTs',obj.accelTs);
            addOptional(p,'velTs',obj.velTs);
            addOptional(p,'dispTs',obj.dispTs);
            addOptional(p,'integratorType',obj.integratorType);
            addOptional(p,'cFactor',obj.cFactor);
            parse(p,tag,varargin{:});
            
            % store variables
            obj.tag = tag;
            
            % command line open
            obj.cmdLine = ['groundMotion ' num2str(obj.tag) ' Plain'];
            
            if any(ismember(p.UsingDefaults,'accelTs')) == 0
                
                % store variable
                obj.accelTs = p.Results.accelTs;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -accel ' num2str(obj.accelTs.tag)];
                
            end
            
            if any(ismember(p.UsingDefaults,'velTs')) == 0
                
                % store variable
                obj.velTs = p.Results.velTs;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -vel ' num2str(obj.velTs.tag)];
                
            end
            
            if any(ismember(p.UsingDefaults,'dispTs')) == 0
                
                % store variable
                obj.dispTs = p.Results.dispTs;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -disp ' num2str(obj.dispTs.tag)];
                
            end
            
        end
                
    end
    
end