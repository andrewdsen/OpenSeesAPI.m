% This command is used to construct a DisplacementControl integrator object. In an analysis step
% with Displacement Control we seek to determine the time step that will result in a displacement 
% increment for a particular degree-of-freedom at a node to be a prescribed value.
% 
% Ref: http://opensees.berkeley.edu/wiki/index.php/Displacement_Control
%
% tcl syntax:
% integrator DisplacementControl $node $dof $incr <$numIter $?Umin $?Umax>
%
% MATLAB syntax:
% DisplacementControl(node,dof,incr,<numIter,DUmin,DUmax>)

classdef DisplacementControl < OpenSees
    
    properties
        
        format = '%0.5f'; % string format
        
        node     % control node
        dof      % control degree of freedom
        incr     % first displacement increment
        numIter  % number of iterations (optional)
        DUmin    % minimum step size allowed (optional)
        DUmax    % maximum step size allowed (optional)
        
    end
    
    methods
        
        function obj = DisplacementControl(node,dof,incr,numIter,DUmin,DUmax)
            
            % store variables
            obj.node = node;
            obj.dof = dof;
            obj.incr = incr;
            
            % command line open
            obj.cmdLine = ['integrator DisplacementControl ' ...
                           num2str(obj.node.tag) ' ' ...
                           num2str(obj.dof) ' ' ...
                           num2str(obj.incr,obj.format)];
                       
            if nargin == 6
                
                % store variables
                obj.numIter = numIter;
                obj.DUmin = DUmin;
                obj.DUmax = DUmax;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.numIter) ' ' ...
                               num2str(obj.DUmin,obj.format) ' ' ...
                               num2str(obj.DUmax,obj.foramt)];
                           
            end
            
        end
        
    end
    
end