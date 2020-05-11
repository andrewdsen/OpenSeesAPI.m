classdef Aggregator < OpenSees.model.section
    
    properties
        
%         tag = [];   % unique section tag
        mat = [];   % array of OpenSees materials
        dof = {};   % cell array of dofs corresponding to materials
                    % acceptable values:
                    % P     Axial force-deformation
                    % Mz    Moment-curvature about section local z-axis
                    % Vy    Shear force-deformation along section local y-axis
                    % My    Moment-curvature about section local y-axis
                    % Vz    Shear force-deformation along section local z-axis
                    % T     Torsion force-deformation
        sec = [];   % previously-defined section object
        
    end
    
    methods
       
        function obj = Aggregator(tag, mat, dof, sec)
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.dof = dof;
            
            if length(obj.mat) ~= length(obj.dof)
                error('Number of materials and number of dofs must match!');
            else
                n = length(obj.mat);
            end
            
            % command line open
            obj.cmdLine = ['section Aggregator ' num2str(obj.tag)];
            
            for ii = 1:n
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.mat(ii).tag) ' ' obj.dof{ii}];
            end
            
            if nargin == 4
                obj.sec = sec;
                obj.cmdLine = [obj.cmdLine ' -section ' num2str(obj.sec.tag)];
            end
            
        end
        
    end
    
end