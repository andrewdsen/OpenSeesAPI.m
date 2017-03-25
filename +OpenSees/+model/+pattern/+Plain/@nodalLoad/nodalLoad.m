% This command is used to construct a NodalLoad object and add it to the enclosing LoadPattern.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/NodalLoad_Command
%
% tcl syntax:
% load $nodeTag (ndf $LoadValues)
%
% MATLAB syntax:
% nodalLoad(nodeTag,loadValues)

classdef nodalLoad < OpenSees
   
    properties
        
        format = '%0.5f '; % string format
        
        node       % node object
        loadValues % load values at node degrees of freedom
        
    end
    
    methods
        
        function obj = nodalLoad(node,loadValues)
           
            ndf = nargin - 1;
            if ndf > 6
                error('invalid number of input arguments');
            end
            
            % store variables
            obj.node = node;
            obj.loadValues = loadValues;
            
            % command line open
            obj.cmdLine = ['load ' num2str(obj.node.tag) ' ' num2str(obj.loadValues,obj.format)];
            
        end
        
    end
    
end