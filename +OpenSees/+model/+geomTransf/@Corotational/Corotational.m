% This command is used to construct the Corotational Coordinate Transformation (CorotCrdTransf) 
% object. Corotational transformation can be used in large displacement-small strain problems. 
% NOTE: Currently the transformation does not deal with element loads and will ignore any that are 
% applied to the element.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Corotational_Transformation
%
% tcl syntax:
% 2D | geomTransf Corotational $transfTag <-jntOffset $dXi $dYi $dXj $dYj>
% 3D | geomTransf Corotational $transfTag $vecxzX $vecxzY $vecxzZ
%
% Note: Rigid joint offsets are not supported here. They are not recommended due to numerical
% issues. Instead, use elastic beam-column elements with high stiffness.
%
% MATLAB syntax:
%

classdef Corotational < OpenSees
    
    properties
        
        format = ' %0.5f';
        
        tag = [];   % geometric transfer tag
        vecxz = []; % vector in plane parallel to x-z plane of local-coordinate system
        
    end
    
    methods
        
        function obj = Corotational(tag,vecxz)
            
            if nargin >= 1
                
                % store variables
                obj.tag = tag;
                
                % command line open
                obj.cmdLine = ['geomTransf Corotational ' num2str(obj.tag)];
                
            end
            
            if nargin == 2
                
                % store variables
                obj.vecxz = vecxz;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.vecxz)];
                
            end
            
        end
        
    end
    
end
                               
