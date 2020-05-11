% This commnand allows the user to construct a FiberSection object. Each FiberSection object is 
% composed of Fibers, with each fiber containing a UniaxialMaterial, an area and a location (y,z). 
% The command to generate FiberSection object contains in { } the commands to generate all the 
% fibers in the object. To construct a FiberSection and populate it, the following command is used:
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Fiber_Section
%
% tcl syntax:
% section Fiber $secTag <-GJ $GJ> { };
%
% MATLAB syntax:
%

classdef Fiber < OpenSees
    
    properties
        
        format = '%0.5f';
        
        % required
        tag = [];       % section tag
        fibers = [];    % array of fibers created by fiber, patch, or layer commands
        
        % optional 
        GJ = [];    % linear-elastic trosional stiffness assigned to the section
        
    end
    
    methods
        
        function obj = Fiber(tag, fibers, GJ)
            
            if nargin >= 2
            
                % store variables
                obj.tag = tag;
                obj.fibers = fibers;
            
                % command line open
                obj.cmdLine = ['section Fiber ' num2str(obj.tag)];
                
            end
            
            if nargin == 3
                
                % store variable
                obj.GJ = GJ;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -GJ ' num2str(GJ,obj.format)];
                
            end
            
            % command line add
            obj.cmdLine = [obj.cmdLine ' {\n'];
            
            for ii = 1:size(obj.fibers,1)
               
                % command line add
                obj.cmdLine = [obj.cmdLine '\t' obj.fibers(ii).cmdLine '\n'];
                
            end
            
            % command line close
            obj.cmdLine = [obj.cmdLine '}'];

        end
            
    end
    
end
        