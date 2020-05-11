% The following is the command to generate a quadrilateral shaped patch 
% (the geometry of the patch is defined by four vertices: I J K L. The 
% coordinates of each of the four vertices is specified in COUNTER 
% CLOCKWISE sequence):
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Patch_Command
%
% tcl syntax:
% patch quad $matTag $numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
% 
% MATLAB syntax:
%

classdef quad < OpenSees
    
    properties
        
        format = ' %0.5f'; % string format
        
        mat = [];       % tag of previously defined material
        nfij = [];      % number of fibers in ij direction
        nfjk = [];      % number of fibers in jk direction
        iCoords = [];   % y- and z-coordinates for vertex i in local coordinate system (base)
        jCoords = [];   % y- and z-coordinates for vertex j in local coordinate system (CCW from i)
        kCoords = [];   % y- and z-coordinates for vertex k in local coordinate system (CCW from j)
        lCoords = [];   % y- and z-coordinates for vertex k in local coordinate system (CCW from k)

    end
    
    methods
        
        function obj = quad(mat, nfij, nfjk, iCoords, jCoords, kCoords, lCoords)
            
            % store variables
            obj.mat = mat;
            obj.nfij = nfij;
            obj.nfjk = nfjk;
            obj.iCoords = iCoords;
            obj.jCoords = jCoords;
            obj.kCoords = kCoords;
            obj.lCoords = lCoords;
            
            if size(obj.iCoords,1) == 2
                obj.iCoords = obj.iCoords.';
            end
            if size(obj.jCoords,1) == 2
                obj.jCoords = obj.jCoords.';
            end
            if size(obj.kCoords,1) == 2
                obj.kCoords = obj.kCoords.';
            end
            if size(obj.lCoords,1) == 2
                obj.lCoords = obj.lCoords.';
            end
            
            % command line open
            obj.cmdLine = ['patch quad ' num2str(obj.mat.tag) ' ' ...
                           num2str(obj.nfij) ' ' ...
                           num2str(obj.nfjk) ' ' ...
                           num2str(obj.iCoords, obj.format) ' ' ...
                           num2str(obj.jCoords, obj.format) ' ' ...
                           num2str(obj.kCoords, obj.format) ' ' ...
                           num2str(obj.lCoords, obj.format)];
                       
        end
        
    end
    
end