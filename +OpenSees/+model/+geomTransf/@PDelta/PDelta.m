% This command is used to construct a linear coordinate transformation (LinearCrdTransf) object, 
% which performs a linear geometric transformation of beam stiffness and resisting force from the 
% basic system to the global-coordinate system.
%
% For a two-dimensional problem:
% geomTransf Linear $transfTag <-jntOffset $dXi $dYi $dXj $dYj>
%
% For a three-dimensional problem:
% geomTransf Linear $transfTag $vecxzX $vecxzY $vecxzZ <-jntOffset $dXi $dYi $dZi $dXj $dYj $dZj>
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Linear_Transformation
%
% MATLAB syntax:
% Linear(tag,vecxzX,vecxzY,vecxzZ)

classdef PDelta < OpenSees
    
    properties
        
        format = ' %0.5f';
        
        tag = [];   % geometric transfer tag
        vecxz = []; % vector in plane parallel to x-z plane of local-coordinate system
        jntOffset = []; % vector of joint offsets with respect to global coordinate system
        
    end
    
    methods
        
        function obj = PDelta(tag,vecxz,jntOffset)
            
            if nargin >= 1
                
                % store variables
                obj.tag = tag;
                
                % command line open
                obj.cmdLine = ['geomTransf PDelta ' num2str(obj.tag)];
                
            end
            
            if nargin >= 2
                
                % store variables
                obj.vecxz = vecxz;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.vecxz)];
                
            end
            
            if nargin == 3
                
                % store variables
                obj.jntOffset = jntOffset;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -jntOffset ' num2str(obj.jntOffset)];
                
            end
            
        end
        
    end
    
end