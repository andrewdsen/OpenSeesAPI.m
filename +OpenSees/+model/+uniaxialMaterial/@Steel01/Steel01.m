% This command is used to construct an elastic perfectly-plastic gap uniaxial material object.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic-Perfectly_Plastic_Gap_Material
% 
% tcl syntax:
% uniaxialMaterial ElasticPPGap $matTag $E $Fy $gap <$eta> <damage>
%
% MATLAB syntax:
% 

classdef Steel01 < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.8f';   % string format
        
        % required
        E = [];         % tangent
        Fy = [];        % stress or force at which material reaches plastic state
        b = [];         % 
                        
    end
    
    methods
        
        function obj = Steel01(tag,Fy,E,b)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'E');
            addRequired(p,'Fy');
            addRequired(p,'b');
            parse(p,tag,Fy,E,b);
            
            % store variables
            obj.tag = tag;
            obj.E = E;
            obj.Fy = Fy;
            obj.b = b;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Steel01 ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.Fy,obj.format) ' ' ...
                           num2str(obj.E,obj.format) ' ' ...
                           num2str(obj.b,obj.format)];
            
        end
        
    end
    
end
        