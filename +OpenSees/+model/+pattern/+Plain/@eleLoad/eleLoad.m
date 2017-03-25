% The eleLoad command is used to construct an ElementalLoad object and add it to the enclosing LoadPattern.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/EleLoad_Command
%
% tcl syntax:
% load -ele $eleTag <$eleTag2 ...> -type -beamUniform $Wy $Wz <$Wx>
%
% MATLAB syntax:
% eleLoad(node_tag, ele_tag, ele_load)
%
% TO DO: Switching for 2D/3D

classdef eleLoad < OpenSees
   
    properties
        
        format = '%0.5f'; % string format
        
        ele         % predefined element object(s)
        ele_load    % load values 
        
    end
    
    methods
        
        function obj = eleLoad(ele, ele_load)
                       
            % store variables
            obj.ele = ele;
            obj.ele_load = ele_load;
            
            ele_tag = [];
            for ii = 1:length(obj.ele)
                ele_tag = horzcat(ele_tag, obj.ele(ii).tag);
            end
            
            % command line open
            obj.cmdLine = ['eleLoad -ele ' num2str(ele_tag, ' %0g') ' -type -beamUniform ' ...
                           num2str(obj.ele_load(2), obj.format) ' ' ...
                           num2str(obj.ele_load(3), obj.format) ' ' ...
                           num2str(obj.ele_load(1), obj.format)];
            
        end
        
    end
    
end