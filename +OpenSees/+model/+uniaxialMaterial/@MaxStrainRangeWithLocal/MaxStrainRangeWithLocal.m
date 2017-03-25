classdef MaxStrainRangeWithLocal < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = ' %0.8f'; % string format
        
        % required
        preMat = [];    % pre-fracture material object
        limitSR = [];   % fracture limit for strain range
        limitCS = [];   % compressive strain limit
        localPen = [];  % stress penalty if compressive strain limit is reached
        
        % optional
        minStrain = []; % minimum strain required for fracture
        maxStrain = []; % maximum strain required for fracture
        
    end
    
    methods
        
        function obj = MaxStrainRangeWithLocal(tag,preMat,limitSR,limitCS,localPen,varargin)
           
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'preMat');
            addRequired(p,'limitSR');
            addRequired(p,'limitCS');
            addRequired(p,'localPen');
            addOptional(p,'minStrain',obj.minStrain);
            addOptional(p,'maxStrain',obj.maxStrain);
            parse(p,tag,preMat,limitSR,limitCS,localPen,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.preMat = preMat;
            obj.limitSR = limitSR;
            obj.limitCS = limitCS;
            obj.localPen = localPen;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial MaxStrainRangeWithLocal ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.preMat.tag) ' ' ...
                           num2str(obj.limitSR,obj.format) ' ' ...
                           num2str(obj.limitCS,obj.format) ' ' ...
                           num2str(obj.localPen,obj.format)];
            
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

        end
        
    end
    
end