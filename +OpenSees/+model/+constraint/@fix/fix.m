% This command is used to construct single-point homogeneous boundary constraints.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Fix_command
%
% tcl syntax:
% fix $nodeTag (ndf $constrValues)
%
% MATLAB syntax:
% 

classdef fix < OpenSees
    
    properties
        
        format = '% 1g'; % string format
        
        node        % node object
        constrProps % constraint properties at node degrees of freedom
        
    end
    
    methods
        
        function obj = fix(node,constrProps)
            
            ndf = nargin - 1;
            if ndf > 6
                error('invalid number of input arguments');
            end
            
            % store variables
            obj.node = node;
            obj.constrProps = constrProps;
            
            % command line open
            obj.cmdLine = ['fix ' num2str(obj.node.tag) ' ' num2str(obj.constrProps,obj.format)];
            
        end
        
    end
    
end