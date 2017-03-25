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

classdef zeroLengthSection < OpenSees.model.element
   
    properties
        
        format = ' %0.9f'; % string format
        
        iNode       %  
        jNode       % 
        sec         %
        x = [];     % 
        yp = [];    % 
        rFlag = 0;  % 
                
    end
    
    methods
        
        function obj = zeroLengthSection(tag,iNode,jNode,sec,varargin)
           
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'iNode');
            addRequired(p,'jNode');
            addRequired(p,'sec');
            addOptional(p,'x',obj.x);
            addOptional(p,'yp',obj.yp);
            addOptional(p,'rFlag',obj.rFlag);
            parse(p,tag,iNode,jNode,sec,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.sec = sec;
            
            % command line open
            obj.cmdLine = ['element zeroLengthSection ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str([obj.sec.tag])];
            
            if any(ismember(p.UsingDefaults,'x')) == 0 && any(ismember(p.UsingDefaults,'yp')) == 0
                
                % store variables
                obj.x = p.Results.x;
                obj.yp = p.Results.yp;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-orient ' num2str(obj.x,obj.format) ' ' num2str(obj.yp,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'rFlag')) == 0
                
                % store variables
                obj.rFlag = p.Results.rFlag;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-doRayleigh ' num2str(obj.rFlag)];
                
            end
            
        end
        
    end
    
end
