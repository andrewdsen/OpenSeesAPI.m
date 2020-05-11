% The following is the command to generate a rectangular patch. The geometry of the patch is defined
% by coordinates of vertices: I and J. The first vertex, I, is the bottom-left point and the second 
% vertex, J, is the top-right point, having as a reference the local y-z plane.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Patch_Command
%
% tcl syntax:
% patch rect $matTag $numSubdivY $numSubdivZ $yI $zI $yJ $zJ
% 
% MATLAB syntax:
%

classdef straight < OpenSees
    
    properties
        
        format = ' %0.5f'; % string format

        % required
        mat = [];       % material tag associated with this fiber
        numFiber;
        areaFiber;
        
        % required
        iCoords;
        jCoords;

    end
    
    methods
        
        function obj = straight(mat, numFiber, areaFiber, iCoords, jCoords)
            
            % store variables
            obj.mat = mat;
            obj.numFiber = numFiber;
            obj.areaFiber = areaFiber;
            obj.iCoords = iCoords;
            obj.jCoords = jCoords;
            
            % command line open
            obj.cmdLine = ['layer straight ' num2str(obj.mat.tag) ' ' ...
                           num2str(obj.numFiber) ' ' ...
                           num2str(obj.areaFiber) ' ' ...
                           num2str(obj.iCoords, obj.format) ' ' ...
                           num2str(obj.jCoords, obj.format)];
                       
        end
        
    end
    
end