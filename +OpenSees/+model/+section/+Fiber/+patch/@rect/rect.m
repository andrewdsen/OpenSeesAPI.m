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

classdef rect < OpenSees
    
    properties
        
        format = ' %0.5f'; % string format
        
        mat = [];       % tag of previously defined material
        nfy = [];       % number of fibers in local y direction
        nfz = [];       % number of fibers in local z direction
        iCoords = [];   % y- and z-coordinates for vertex i in local coordinate system (bottom left)
        jCoords = [];   % y- and z-coordinates for vertex j in local coordinate system (top right)

    end
    
    methods
        
        function obj = rect(mat, nfy, nfz, iCoords, jCoords)
            
            % store variables
            obj.mat = mat;
            obj.nfy = nfy;
            obj.nfz = nfz;
            obj.iCoords = iCoords;
            obj.jCoords = jCoords;
            
            if size(obj.iCoords,1) == 2
                obj.iCoords = obj.iCoords.';
            end
            if size(obj.jCoords,1) == 2
                obj.jCoords = obj.jCoords.';
            end
            
            % command line open
            obj.cmdLine = ['patch rect ' num2str(obj.mat.tag) ' ' ...
                           num2str(obj.nfy) ' ' ...
                           num2str(obj.nfz) ' ' ...
                           num2str(obj.iCoords,obj.format) ' ' ...
                           num2str(obj.jCoords,obj.format)];
                       
        end
        
    end
    
end