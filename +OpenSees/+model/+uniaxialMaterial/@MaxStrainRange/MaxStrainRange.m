classdef MaxStrainRange < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = ' %0.8f'; % string format
        
        % required
        preMat = [];    % pre-fracture material object
        limitSR = [];   % fracture limit for strain range
        
        % optional
        minStrain = []; % minimum strain required for fracture
        maxStrain = []; % maximum strain required for fracture
        tangentRatio = [];  % ratio of post-fracture stiffness to elastic stiffness
        
    end
    
    methods
        
        function obj = MaxStrainRange(tag,preMat,limitSR,varargin)
           
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'preMat');
            addRequired(p,'limitSR');
            addOptional(p,'minStrain',obj.minStrain);
            addOptional(p,'maxStrain',obj.maxStrain);
            addOptional(p,'tangentRatio',obj.tangentRatio);
            parse(p,tag,preMat,limitSR,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.preMat = preMat;
            obj.limitSR = limitSR;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial MaxStrainRange ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.preMat.tag) ' ' ...
                           num2str(obj.limitSR,obj.format)];
                                
            if any(ismember(p.UsingDefaults,'minStrain')) == 0
                
                % store variable
                obj.minStrain = p.Results.minStrain;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -min ' num2str(obj.minStrain,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'maxStrain')) == 0
                
                % store variable
                obj.maxStrain = p.Results.maxStrain;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -max ' num2str(obj.maxStrain,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'tangentRatio')) == 0
                
                % store variable
                obj.tangentRatio = p.Results.tangentRatio;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -tangentRatio ' num2str(obj.tangentRatio,obj.format)];
                
            end
            
        end
        
    end
    
end