% This command is used to construct a parallel material object made up of an arbitrary number of 
% previously constructed UniaxialMaterial objects.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Parallel_Material
%
% tcl syntax:
% uniaxialMaterial Parallel $matTag $tag1 $tag2 ...
% 
% MATLAB syntax:
% 

classdef Parallel < OpenSees
    
    properties
        
        tag = [];   % integer tag identifying material
        mat = [];   % array of previously defined materials
        
    end
    
    methods
        
        function obj = Parallel(tag,mat)
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Parallel ' ...
                           num2str(obj.tag)];
                       
            for ii = 1:length(obj.mat)
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.mat(ii).tag)];
                           
            end
            
        end
        
    end
    
end