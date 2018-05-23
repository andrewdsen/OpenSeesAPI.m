% This command is used to construct a zeroLength element object, which is defined by two nodes at 
% the same location. The nodes are connected by multiple UniaxialMaterial objects to represent the 
% force-deformation relationship for the element.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/ZeroLength_Element
%
% tcl syntax:
% element zeroLength $eleTag $iNode $jNode -mat $matTag1 $matTag2 ... -dir $dir1 $dir2 ...
% <-doRayleigh $rFlag> <-orient $x1 $x2 $x3 $yp1 $yp2 $yp3>
%
% MATLAB syntax:
% zeroLength(tag,iNode,jNode,mat,matDir,<x,yp>,<rFlag>)

classdef CoupledZeroLength < OpenSees.model.element & matlab.mixin.Copyable
   
    properties
        
        format = ' %0.5f'; % string format
        
        iNode       %  
        jNode       % 
        mat         % 
        matDir      % 
%         x = [];     % 
%         yp = [];    % 
%         rFlag = 0;  % 
                
    end
    
    methods
        
        function obj = CoupledZeroLength(tag,iNode,jNode,mat,matDir)
           
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'iNode');
            addRequired(p,'jNode');
            addRequired(p,'mat');
            addRequired(p,'matDir');
%             addOptional(p,'x',obj.x);
%             addOptional(p,'yp',obj.yp);
%             addOptional(p,'rFlag',obj.rFlag);
            parse(p,tag,iNode,jNode,mat,matDir);
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.mat = mat;
            obj.matDir = matDir;
            
            % command line open
            obj.cmdLine = ['element CoupledZeroLength ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.matDir(1)) ' ' ...
                           num2str(obj.matDir(2)) ' ' ...
                           num2str(obj.mat.tag) ' ' ...
                           num2str(obj.mat.tag)];
            
        end
                
    end
    
end
