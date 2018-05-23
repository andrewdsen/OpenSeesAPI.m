classdef MaxStrainRange < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = ' %0.8f'; % string format
        format_tag = ' %0.0f';
        
        % required
        preMat = [];    % pre-fracture material object
        limitSR = [];   % fracture limit for strain range
        
        % optional
        minStrain = []; % minimum strain required for fracture
        maxStrain = []; % maximum strain required for fracture
        tangentRatio = [];  % ratio of post-fracture stiffness to elastic stiffness
        eleTag = [];    % array of element tags to be removed on failure
        nodeTags = [];
        floorSR = [];
        defCoeff = [];
        
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
            addOptional(p,'eleTag',obj.eleTag);
            addOptional(p,'nodeTags',obj.nodeTags);
            addOptional(p,'floorSR',obj.floorSR);
            addOptional(p,'defCoeff',obj.defCoeff);
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
            
            if any(ismember(p.UsingDefaults,'floorSR')) == 0
                
                % store variable
                obj.floorSR = p.Results.floorSR;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -floor ' num2str(obj.floorSR,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'defCoeff')) == 0
                
                % store variable
                obj.defCoeff = p.Results.defCoeff;
                
                % command line add
                if obj.defCoeff
                    obj.cmdLine = [obj.cmdLine ' -defCoeff ' num2str(obj.defCoeff, obj.format)];
                end
                
            end
            
            if any(ismember(p.UsingDefaults,'eleTag')) == 0
                
                % store variable
                obj.eleTag = p.Results.eleTag;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -eleTag ' num2str(obj.eleTag,obj.format_tag)];
                
            end
            
            if any(ismember(p.UsingDefaults,'nodeTags')) == 0
                
                % store variable
                obj.nodeTags = p.Results.nodeTags;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -nodeTags ' num2str(obj.nodeTags,obj.format_tag)];
                
            end
            
        end
        
        function rewrite(obj)
            
            obj.cmdLine = ['uniaxialMaterial MaxStrainRange ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.preMat.tag) ' ' ...
                           num2str(obj.limitSR,obj.format)];
                                
            if ~isempty(obj.minStrain)

                % command line add
                obj.cmdLine = [obj.cmdLine ' -min ' num2str(obj.minStrain,obj.format)];
                
            end
            
            if ~isempty(obj.maxStrain)
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -max ' num2str(obj.maxStrain,obj.format)];
                
            end
            
            if ~isempty(obj.tangentRatio)

                % command line add
                obj.cmdLine = [obj.cmdLine ' -tangentRatio ' num2str(obj.tangentRatio,obj.format)];
                
            end
            
            if ~isempty(obj.floorSR)

                % command line add
                obj.cmdLine = [obj.cmdLine ' -floor ' num2str(obj.floorSR,obj.format)];
                
            end
            
            if obj.defCoeff

                % command line add
                obj.cmdLine = [obj.cmdLine ' -defCoeff ' num2str(obj.defCoeff, obj.format)];
                
            end
            
            if ~isempty(obj.eleTag)

                % command line add
                obj.cmdLine = [obj.cmdLine ' -eleTag ' num2str(obj.eleTag,obj.format_tag)];
                
            end
            
            if ~isempty(obj.nodeTags)

                % command line add
                obj.cmdLine = [obj.cmdLine ' -nodeTags ' num2str(obj.nodeTags,obj.format_tag)];
                
            end 
            
        end
        
    end
    
end