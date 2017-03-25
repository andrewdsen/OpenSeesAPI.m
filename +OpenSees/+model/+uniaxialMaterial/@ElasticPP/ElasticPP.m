% This command is used to construct an elastic perfectly-plastic gap uniaxial material object.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic-Perfectly_Plastic_Gap_Material
% 
% tcl syntax:
% uniaxialMaterial ElasticPPGap $matTag $E $Fy $gap <$eta> <damage>
%
% MATLAB syntax:
% 

classdef ElasticPP < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.8f';   % string format
        
        % required
        E = [];         % tangent
        epsyP = [];     % strain or deformation at which material reaches plastic state in tension
        
        % optional
        epsyN = [];     % strain or deformation at which material reaches plastic state in compression
        eps0 = 0;       % initial strain
                        
    end
    
    methods
        
        function obj = ElasticPP(tag, E, epsyP, varargin)
            
            p = inputParser;
            addRequired(p, 'tag');
            addRequired(p, 'E');
            addRequired(p, 'epsyP');
            addOptional(p, 'epsyN', obj.epsyN);
            addOptional(p, 'eps0', obj.eps0);
            parse(p, tag, E, epsyP, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.E = E;
            obj.epsyP = epsyP;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial ElasticPP ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.E, obj.format) ' ' ...
                           num2str(obj.epsyP, obj.format)];
            
            if any(ismember(p.UsingDefaults, 'epsyN')) == 0
                
                % store variable
                obj.epsyN = p.Results.epsyN;
                
                if any(ismember(p.UsingDefaults, 'eps0')) == 0
                   
                    % store variable
                    obj.eps0 = p.Results.eps0;
                    
                end
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.epsyN, obj.format) ' ' ...
                               num2str(obj.eps0, obj.format)];

                           
            end
            
        end
        
    end
    
end
        