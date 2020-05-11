% This command is used to construct a line of fibers along a circular arc:
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Layer_Command
%
% tcl syntax:
% layer circ $matTag $numFiber $areaFiber $yCenter $zCenter $radius <$startAng $endAng>
% 
% MATLAB syntax:
%

classdef circ < OpenSees
    
    properties
        
        format = ' %0.5f'; % string format

        % required
        mat = [];   % material object associated with this fiber
        numFiber;   % number of fibers along arc
        areaFiber;  % area of each fiber
        yCenter;    % y-coordinate of center of circular arc
        zCenter;    % z-coordinate of center of circular arc
        radius;     % radius of circular arc
        
        % optional
        startAng;   % starting angle (default = 0.0)
        endAng;     % ending angle (default = 360 - 360/numFiber)

    end
    
    methods
        
        function obj = circ(mat, numFiber, areaFiber, yCenter, zCenter, radius, startAng, endAng)
            
            if nargin >= 6
            
                % store variables
                obj.mat = mat;
                obj.numFiber = numFiber;
                obj.areaFiber = areaFiber;
                obj.yCenter = yCenter;
                obj.zCenter = zCenter;
                obj.radius = radius;

                % command line open
                obj.cmdLine = ['layer circ ' num2str(obj.mat.tag) ' ' ...
                               num2str(obj.numFiber) ' ' ...
                               num2str(obj.areaFiber) ' ' ...
                               num2str(obj.yCenter, obj.format) ' ' ...
                               num2str(obj.zCenter, obj.format) ' ' ...
                               num2str(obj.radius, obj.format)];
                           
            end
            
            if nargin == 8
                
                % store variables
                obj.startAng = startAng;
                obj.endAng = endAng;
                
                % command line
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.startAng, obj.format) ' ' ...
                               num2str(obj.endAng, obj.format)];
                
            end
                       
        end
        
    end
    
end