% This command is used to construct an elastic perfectly-plastic gap uniaxial material object.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic-Perfectly_Plastic_Gap_Material
% 
% tcl syntax:
% uniaxialMaterial ElasticPPGap $matTag $E $Fy $gap <$eta> <damage>
%
% MATLAB syntax:
% 

classdef ElasticPPGap < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.8f';   % string format
        
        % required
        E = [];         % tangent
        Fy = [];        % stress or force at which material reaches plastic state
        gap = [];       % intiial gap (strain or deformation)
        
        % optional
        eta = [];       % hardening ratio (Eh/E) (can be negative)
        damage = 'off'; % optional string to turn on damage accumulation:
                        % | off (default)   no damage accumulation
                        % | on              damage accumulation
                        
    end
    
    methods
        
        function obj = ElasticPPGap(tag,E,Fy,gap,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'E');
            addRequired(p,'Fy');
            addRequired(p,'gap');
            addOptional(p,'eta',obj.eta);
            addOptional(p,'damage',obj.damage);
            parse(p,tag,E,Fy,gap,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.E = E;
            obj.Fy = Fy;
            obj.gap = gap;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial ElasticPPGap ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.E,obj.format) ' ' ...
                           num2str(obj.Fy,obj.format) ' ' ...
                           num2str(obj.gap,obj.format)];
            
            if any(ismember(p.UsingDefaults,'eta')) == 0
                
                % store variable
                obj.eta = p.Results.eta;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.eta,obj.format)];
                           
            end
            
            if any(ismember(p.UsingDefaults,'damage')) == 0
                
                if strcmp(p.Results.damage,'on')
                    
                    % store variable
                    obj.damage = p.Results.damage;

                    % command line add
                    obj.cmdLine = [obj.cmdLine ' damage'];
                    
                end
                           
            end
            
        end
        
    end
    
end
        