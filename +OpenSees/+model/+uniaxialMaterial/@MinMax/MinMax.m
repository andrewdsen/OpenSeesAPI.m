% This command is used to construct a MinMax material object. This stress-strain behaviour for this 
% material is provided by another material. If however the strain ever falls below or above certain 
% threshold values, the other material is assumed to have failed. From that point on, values of 0.0 
% are returned for the tangent and stress.
% 
% Ref: http://opensees.berkeley.edu/wiki/index.php/MinMax_Material
%
% tcl syntax:
% uniaxialMaterial MinMax $matTag $otherTag <-min $minStrain> <-max $maxStrain>
% 
% MATLAB syntax:
% 

classdef MinMax < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.8f';   % string format
        
        % required
        origMat = [];   % original material object
        
        % optional
        minStrain = []; % minimum value of strain
        maxStrain = []; % maximum value of strain
        
    end
    
    methods
        
        function obj = MinMax(tag,origMat,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'origMat');
            addOptional(p,'minStrain',obj.minStrain);
            addOptional(p,'maxStrain',obj.maxStrain);
            parse(p,tag,origMat,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.origMat = origMat;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial MinMax ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.origMat.tag)];

            if any(ismember(p.UsingDefaults,'minStrain')) == 0
                
                % store variable
                obj.minStrain = p.Results.minStrain;
                
                % comand line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-min ' num2str(obj.minStrain,obj.format)];
                           
            end
            
            if any(ismember(p.UsingDefaults,'maxStrain')) == 0
                
                % store variable
                obj.maxStrain = p.Results.maxStrain;
                
                % comand line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-max ' num2str(obj.maxStrain,obj.format)];
                           
            end
            
        end
        
    end

end