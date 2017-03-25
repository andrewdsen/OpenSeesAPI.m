% This command is used to construct a series material object made up of an arbitrary number of 
% previously constructed UniaxialMaterial objects.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Series_Material
%
% tcl syntax:
% uniaxialMaterial Series $matTag $tag1 $tag2 ...
% 
% MATLAB syntax:
% 

classdef Series < OpenSees.model.uniaxialMaterial
    
    properties
        
        mat = [];   % array of previously defined materials
        
    end
    
    methods
        
        function obj = Series(tag,mat)
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Series ' ...
                           num2str(obj.tag)];
                       
            for ii = 1:length(obj.mat)
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.mat(ii).tag)];
                           
            end
            
        end
        
    end
    
end