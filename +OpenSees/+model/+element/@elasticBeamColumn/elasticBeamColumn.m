% This command is used to construct an elasticBeamColumn element object. The arguments for the 
% construction of an elastic beam-column element depend on the dimension of the problem, ndm:
%
% For a two-dimensional problem:
% element elasticBeamColumn $eleTag $iNode $jNode $A $E $Iz $transfTag <-mass $massDens> <-cMass>
%
% For a three-dimensional problem:
% element elasticBeamColumn $eleTag $iNode $jNode $A $E $G $J $Iy $Iz $transfTag ...
%                           <-mass $massDens> <-cMass>
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic_Beam_Column_Element
%
% elasticBeamColumn(tag,iNode,jNode,A,E,Iz,transfTag,<G,J,Iy>)

classdef elasticBeamColumn < OpenSees.model.element
    
    properties
        
        format = '% 0.3f'; % string format
        
        % if ndm >= 2
        iNode      % start node object
        jNode      % end node object
        A          % cross-sectional area of element
        E          % Young's modulus
        Iz         % second moment of area about the local z-axis
        transf     % coordinate-transformation object
        
        % if ndm == 3
        G          % shear modulus
        J          % torsional moment of inertia of cross section
        Iy         % second moment of area about the local y-axis
        
        % optional - specify with OpenSees.option, see formatting above
        % massDens % element mass per unit length
        % cMass    % form consistent mass matrix
        
    end
    
    methods
        
        function obj = elasticBeamColumn(tag,iNode,jNode,A,E,Iz,transf,G,J,Iy)

            % (perhaps useful for full implementation)
            % ip = inputParser;
            % addOptional(ip,'massDens',[]);
            % addOptional(ip,'cMass',[]);
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.A = A;
            obj.E = E;
            obj.Iz = Iz;
            obj.transf = transf;
            
            % command line open
            obj.cmdLine = ['element elasticBeamColumn ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.A,obj.format) ' ' ...
                           num2str(obj.E,obj.format)];
                       
            % 
            if nargin == 7
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.Iz,obj.format) ' ' ...
                               num2str(obj.transf.tag)];
                           
            elseif nargin == 10
                
                % store variables
                obj.G = G;
                obj.J = J;
                obj.Iy = Iy;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.G,obj.format) ' ' ...
                               num2str(obj.J,obj.format) ' ' ...
                               num2str(obj.Iy,obj.format) ' ' ...
                               num2str(obj.Iz,obj.format) ' ' ...
                               num2str(obj.transf.tag)];
                           
            else
                
                % wrong number of input arguments
                error('invalid number of input arguments');
                
            end
           
   
        end
        
    end
    
end