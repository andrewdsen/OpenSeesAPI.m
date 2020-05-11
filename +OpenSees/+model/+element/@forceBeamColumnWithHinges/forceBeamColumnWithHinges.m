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

classdef forceBeamColumnWithHinges < OpenSees.model.element
    
    properties
   
        format = '% 0.5f'; % string format
        
        % required
        iNode = [];             % start node object
        jNode = [];             % end node object
        transf = [];            % geometric transformation object
        secI = [];              % section object at end i
        secJ = [];              % section object at end j

        % optional
        intType = 'HingeEndpoint';    % integration type, supported types:
                                % | HingeRadau
                                % | HingeRadauTwo
                                % | HingeMidpoint
                                % | HingeEndpoint (default)
        LpI;                    % plastic hinge length at end i
        LpJ;                    % plastic hinge length at end j
        secInterior = [];       % interior section object
        massDens = [];          % element mass density (per unit length), from which a lumped-mass 
                                % matrix is formed
        maxIters = [];          % maximum number of iterations to undertake to satisfy element
                                % compatibility
        tol = [];               % tolerance for satisfaction of element compatibility
        
    end
    
    methods
   
        function obj = forceBeamColumnWithHinges(tag, iNode, jNode, transf, intType, secI, secJ, secInterior, LpI, LpJ, varargin)
           
            p = inputParser;
            addRequired(p, 'tag');
            addRequired(p, 'iNode');
            addRequired(p, 'jNode');
            addRequired(p, 'transf');
            addRequired(p, 'intType');
            addRequired(p, 'secI');
            addRequired(p, 'secJ');
            addRequired(p, 'secInterior');
            addRequired(p, 'LpI');
            addRequired(p, 'LpJ');
            addOptional(p, 'massDens',obj.massDens);
            addOptional(p, 'maxIters',obj.maxIters);
            addOptional(p, 'tol',obj.tol);
            parse(p, tag, iNode, jNode, transf, intType, secI, secJ, secInterior, LpI, LpJ, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.transf = transf;
            obj.intType = intType;
            obj.secI = secI;
            obj.secJ = secJ;
            obj.secInterior = secInterior;
            obj.LpI = LpI;
            obj.LpJ = LpJ;
                        
            % command line open
            obj.cmdLine = ['element forceBeamColumn ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.transf.tag) ' ' ...
                           '"' obj.intType ' ' ...
                           num2str(obj.secI.tag) ' ' ...
                           num2str(obj.LpI, obj.format) ' ' ...
                           num2str(obj.secJ.tag) ' ' ...
                           num2str(obj.LpJ, obj.format) ' ' ...
                           num2str(obj.secInterior.tag) '"'];

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