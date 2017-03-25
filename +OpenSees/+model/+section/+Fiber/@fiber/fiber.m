% This command allows the user to construct a single fiber and add it to the enclosing FiberSection 
% or NDFiberSection.
% 
% Ref: http://opensees.berkeley.edu/wiki/index.php/Fiber_Command
% 
% tcl syntax:
% fiber $yLoc $zLoc $A $matTag
%
% MATLAB syntax:
% 

classdef fiber < OpenSees
    
    properties
    
        format = ' %0.5f'; % string format

        % required
        mat = [];       % material tag associated with this fiber
        coords = [];    % [y z] coordinates of fiber in the section (local)
        A = [];         % area of fiber
    
    end
    
    methods
        
        function obj = fiber(mat,coords,A)
           
            % store variables
            obj.mat = mat;
            obj.coords = coords;
            obj.A = A;
            
            % command line open
            obj.cmdLine = ['fiber ' ...
                           num2str(obj.coords,obj.format) ' ' ...
                           num2str(obj.A,obj.format) ' ' ...
                           num2str(obj.mat.tag)];
            
        end
        
    end
    
end