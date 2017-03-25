% This command is used to construct a forceBeamColumn element object, which is based on the 
% iterative force-based formulation. A variety of numerical integration options can be used in the 
% element state determination and encompass both distributed plasticity and plastic hinge 
% integration. See File:IntegrationTypes.pdf for more details on the available numerical integration
% options.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Force-Based_Beam-Column_Element
%
% tcl syntax:
% element forceBeamColumn $eleTag $iNode $jNode $transfTag "IntegrationType arg1 arg2 ..." ...
% <-mass $massDens> <-iter $maxIters $tol>
%
% MATLAB syntax:
% 

classdef forceBeamColumn < OpenSees.model.element
    
    properties
   
        format = '% 0.5f'; % string format
        
        % required
        iNode = [];             % start node object
        jNode = [];             % end node object
        transf = [];            % geometric transformation object
        sec = [];               % section object

        % optional
        intType = 'Lobatto';    % integration type, supported types:
                                % | Lobatto             Gauss-Lobatto (default)
                                % | Legendre            Gauss-Legendre
                                % | Radau               Gauss-Radau
                                % | NewtonCotes         Newton-Cotes
        np = 5;                 % number of integration points        
        massDens = [];          % element mass density (per unit length), from which a lumped-mass 
                                % matrix is formed
        maxIters = [];          % maximum number of iterations to undertake to satisfy element
                                % compatibility
        tol = [];               % tolerance for satisfaction of element compatibility
        
    end
    
    methods
   
        function obj = forceBeamColumn(tag,iNode,jNode,transf,sec,varargin)
           
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'iNode');
            addRequired(p,'jNode');
            addRequired(p,'transf');
            addRequired(p,'sec');
            addOptional(p,'intType',obj.intType);
            addOptional(p,'np',obj.np);
            addOptional(p,'massDens',obj.massDens);
            addOptional(p,'maxIters',obj.maxIters);
            addOptional(p,'tol',obj.tol);
            parse(p,tag,iNode,jNode,transf,sec,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.transf = transf;
            obj.sec = sec;
            
            if any(ismember(p.UsingDefaults,'intType')) == 0
                obj.intType = p.Results.intType;
            end
            if any(ismember(p.UsingDefaults,'np')) == 0
                obj.np = p.Results.np;
            end

            
            % command line open
            obj.cmdLine = ['element forceBeamColumn ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.transf.tag) ' ' ...
                           '"' obj.intType ' ' ...
                           num2str(obj.sec.tag) ' ' ...
                           num2str(obj.np) '"'];

            if any(ismember(p.UsingDefaults,'massDens')) == 0
                
                % store variable
                obj.massDens = p.Results.massDens;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-mass ' num2str(obj.massDens,'%0.20f')];
                
            end
            if any(ismember(p.UsingDefaults,'maxIters')) == 0 && ... 
               any(ismember(p.UsingDefaults,'tol')) == 0

                % store variables
                obj.maxIters = p.Results.maxIters;
                obj.tol = p.Results.tol;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-iter ' num2str(obj.maxIters) ' ' ...
                               num2str(obj.tol,'%.9g')];

            end
            
        end
        
    end
    
end