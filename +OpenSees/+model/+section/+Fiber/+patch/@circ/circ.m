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

classdef circ < OpenSees
    
    properties
        
        format = ' %0.5f'; % string format
        
        mat = [];       % tag of previously defined material
        numSubdivCirc = [];
        numSubdivRad = [];
        yCenter = [];
        zCenter = [];
        intRad = [];
        extRad = [];
        startAng = [];
        endAng = [];

    end
    
    methods
        
        function obj = circ(mat,numSubdivCirc,numSubdivRad,yCenter,zCenter,intRad,extRad,startAng,endAng)
            
            % store variables
            obj.mat = mat;
            obj.numSubdivCirc = numSubdivCirc;
            obj.numSubdivRad = numSubdivRad;
            obj.yCenter = yCenter;
            obj.zCenter = zCenter;
            obj.intRad = intRad;
            obj.extRad = extRad;
            obj.startAng = startAng;
            obj.endAng = endAng;
            
            % command line open
            obj.cmdLine = ['patch circ ' num2str(obj.mat.tag) ' ' ...
                           num2str(obj.numSubdivCirc) ' ' ...
                           num2str(obj.numSubdivRad) ' ' ...
                           num2str(obj.yCenter,obj.format) ' ' ...
                           num2str(obj.zCenter,obj.format) ' ' ...
                           num2str(obj.intRad,obj.format) ' ' ...
                           num2str(obj.extRad,obj.format) ' ' ...
                           num2str(obj.startAng,obj.format) ' ' ...
                           num2str(obj.endAng,obj.format)];
                       
        end
        
    end
    
end