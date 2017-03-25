% This command is used to construct a BandGeneralSOE linear system of equation object. As the name 
% implies, this class is used for matrix systems which have a banded profile. The matrix is stored 
% as shown below in a 1dimensional array of size equal to the bandwidth times the number of 
% unknowns. When a solution is required, the Lapack routines DGBSV and SGBTRS are used.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/BandGeneral_SOE
%
% tcl syntax:
% system BandGeneral

classdef BandGeneral < OpenSees
    
    methods
        
        function obj = BandGeneral()
            
            obj.cmdLine = 'system BandGeneral';
            
        end
        
    end
    
end