% This command is used to construct an elastic uniaxial material object.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic_Uniaxial_Material
%
% tcl syntax:
% uniaxialMaterial Elastic $matTag $E <$eta> <$Eneg>
%
% MATLAB syntax:
%

classdef Elastic < OpenSees.model.uniaxialMaterial
    
    properties
    
        format = '%0.16f';
        
        % required
        E = [];     % tangent modulus
        
        % optional
        eta = 0;    % damping tangent
        Eneg = [];  % tangent modulus in compression
        nu = 0;     % Poisson ratio
        
        % output
        G = [];     % shear modulus
        
    end
    
    methods
        
        function obj = Elastic(tag,E,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'E');
            addOptional(p,'eta',obj.eta);
            addOptional(p,'Eneg',obj.Eneg);
            addOptional(p,'nu',obj.nu);
            parse(p,tag,E,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.E = E;
            
            if any(ismember(p.UsingDefaults,'eta')) == 0
                obj.eta = p.Results.eta;
            end
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Elastic ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.E,obj.format) ' ' ...
                           num2str(obj.eta,obj.format)];
                       
            if any(ismember(p.UsingDefaults,'Eneg')) == 0
                
                % store variable
                obj.Eneg = p.Results.Eneg;
                
                % command line 
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.Eneg,obj.format)];
                           
            end
            
            if any(ismember(p.UsingDefaults,'nu')) == 0
                
                % store variable
                obj.nu = p.Results.nu;
                
                obj.G = obj.E/(2*(1 + obj.nu));
                
            end
                
        end
        
    end
    
end