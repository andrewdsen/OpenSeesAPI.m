% This command is used to construct a displacement beam element object, which is based on the
% displacement formulation, and considers the spread of plasticity along the element.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Displacement-Based_Beam-Column_Element
%
% tcl syntax:
% 
% MATLAB syntax:
%

classdef dispBeamColumn < OpenSees.model.element
    
    properties
        
        format = '%0.7f';
        
        % required
        iNode = [];         % start node object
        jNode = [];         % end node object
        sec = [];           % section object
        geomTransf = [];    % geometric transformation object
        
        % optional
        np = 5;             % number of integration points
        massDens = [];      % element mass density from which lumped-mass matrix is formed
        cMass = 'off';      % turn 'on' to form consistent mass matrix
        intType = [];       % numerical integration type
                            % | Lobatto
                            % | Legendre (default)
                            % | Radau
                            % | NewtonCotes
                            % | Trapezoidal
        
    end
    
    methods
        
        function obj = dispBeamColumn(tag,iNode,jNode,geomTransf,sec,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'iNode');
            addRequired(p,'jNode');
            addRequired(p,'geomTransf');
            addRequired(p,'sec');
            addOptional(p,'np',obj.np);
            addOptional(p,'massDens',obj.massDens);
            addOptional(p,'cMass',obj.cMass);
            addOptional(p,'intType',obj.intType);
            parse(p,tag,iNode,jNode,geomTransf,sec,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.geomTransf = geomTransf;
            obj.sec = sec;
            
            if any(ismember(p.UsingDefaults,'np')) == 0
                obj.np = p.Results.np;
            end
            
            % command line open
            obj.cmdLine = ['element dispBeamColumn ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.np) ' ' ...
                           num2str(obj.sec.tag) ' ' ...
                           num2str(obj.geomTransf.tag)];
                       
            if any(ismember(p.UsingDefaults,'massDens')) == 0
                
                % store variable
                obj.massDens = p.Results.massDens;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-mass ' num2str(obj.massDens,' %0.20f')];
                
            end
            
            if any(ismember(p.UsingDefaults,'cMass')) == 0
                
                % store variable
                obj.cMass = p.Results.cMass;
                
                if strcmp(obj.cMass,'on')

                    % command line add
                    obj.cmdLine = [obj.cmdLine ' -cMass' ];
                    
                end
                
            end
           
            if any(ismember(p.UsingDefaults,'intType')) == 0
                
                % store variable
                obj.intType = p.Results.intType;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-integration ' obj.intType];
                
            end
            
        end
        
    end
    
end