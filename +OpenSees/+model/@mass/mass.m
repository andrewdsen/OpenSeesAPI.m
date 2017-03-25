% This command is used to set the mass at a node.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Mass_Command
%
% tcl syntax:
% mass $nodeTag (ndf $massValues)
%
% MATLAB syntax:
%

classdef mass < OpenSees
   
    properties
        
        format = '% 0.9f';  % string format
        
        % input
        node = [];          % integer tag identifying node whose mass is set
        massValues = [];    % ndf nodal mass values corresponding to each DOF
    
    end
    
    methods
        
        function obj = mass(node,massValues)
           
            % store variables
            obj.node = node;
            obj.massValues = massValues;
            
            % command line open
            obj.cmdLine = ['mass ' num2str(obj.node.tag) ' ' ...
                           num2str(obj.massValues,obj.format)];
            
        end
        
    end
        
end