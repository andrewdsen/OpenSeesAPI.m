% This command is used to construct an ElasticTimoshenkoBeam element object. 
% A Timoshenko beam is a frame member that accounts for shear deformations. 
% The arguments for the construction of an elastic Timoshenko beam element 
% depend on the dimension of the problem, ndm:
%
% For a two-dimensional problem:
% element ElasticTimoshenkoBeam $eleTag $iNode $jNode $E $G $A $Iz $Avy $transfTag <-mass $massDens> <-cMass>
%
% For a three-dimensional problem:
% element ElasticTimoshenkoBeam $eleTag $iNode $jNode $E $G $A $Jx $Iy $Iz $Avy $Avz $transfTag <-mass $massDens> <-cMass>
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic_Timoshenko_Beam_Column_Element
%
% ElasticTimoshenkoBeam(tag, iNode, jNode, E, G, A, Iz, Avy, transfTag, <Jx, Iy, Avz>)

classdef ElasticTimoshenkoBeam < OpenSees.model.element
    
    properties
        
        format = '% 0.3f'; % string format
        
        % if ndm >= 2
        iNode      % start node object
        jNode      % end node object
        E          % Young's modulus
        G          % Shear modulus
        A          % cross-sectional area of element
        
        Iz         % second moment of area about the local z-axis
        Avy        % Shear area for the local y-axis
        transf     % coordinate-transformation object
        
        % if ndm == 3
        Jx         % torsional moment of inertia of cross section
        J          % (copy for compatibility with utilities)
        Iy         % second moment of area about the local y-axis
        Avz        % Shear area for the local z-axis
        
        % optional - specify with OpenSees.option, see formatting above
        % massDens % element mass per unit length
        % cMass    % form consistent mass matrix
        
    end
    
    methods
        
        function obj = ElasticTimoshenkoBeam(tag, iNode, jNode, E, G, A, Iz, Avy, transf, Jx, Iy, Avz)

            % (perhaps useful for full implementation)
            % ip = inputParser;
            % addOptional(ip,'massDens',[]);
            % addOptional(ip,'cMass',[]);
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.E = E;
            obj.G = G;
            obj.A = A;
            obj.Iz = Iz;
            obj.Avy = Avy;
            obj.transf = transf;
            
            % command line open
            obj.cmdLine = ['element ElasticTimoshenkoBeam ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.E, obj.format) ' ' ...
                           num2str(obj.G, obj.format) ' ' ...
                           num2str(obj.A, obj.format)];
                       
            if nargin == 9
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.Iz, obj.format) ' ' ...
                               num2str(obj.Avy, obj.format) ' ' ...
                               num2str(obj.transf.tag)];
                           
            elseif nargin == 12
                
                % store variables
                obj.Jx = Jx;
                obj.J = Jx;
                obj.Iy = Iy;
                obj.Avz = Avz;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.Jx, obj.format) ' ' ...
                               num2str(obj.Iy, obj.format) ' ' ...
                               num2str(obj.Iz, obj.format) ' ' ...
                               num2str(obj.Avy, obj.format) ' ' ...
                               num2str(obj.Avz, obj.format) ' ' ...
                               num2str(obj.transf.tag)];
                           
            else
                
                % wrong number of input arguments
                error('invalid number of input arguments');
                
            end
   
        end
        
    end
    
end