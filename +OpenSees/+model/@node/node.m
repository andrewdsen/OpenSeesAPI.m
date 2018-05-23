% This command is used to construct a Node object. It assigns coordinates and masses to the Node 
% object.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Node_command
%
% node(tag,x,<y,z>)

classdef node < OpenSees
    
    properties
             
        tag % node tag
        x   % x-coordinate
        y   % y-coordinate (if ndm >= 2)
        z   % z-coordinate (if ndm == 3)
        flag = [];
        
    end
    
    methods
        
        function obj = node(tag,x,y,z)

            format = '%0.5f '; % string format
            
            % store variable
            obj.tag = tag;
            obj.x = x;
            
            % command line open
            obj.cmdLine = ['node ' num2str(obj.tag) ' ' num2str(obj.x,format)];
            
            if nargin > 2
                
                % store variable
                obj.y = y;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.y,format)];
                
            end
            
            if nargin > 3
                
                % store variable
                obj.z = z;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.z,format)];
                
            end
            
        end
        
    end
    
end