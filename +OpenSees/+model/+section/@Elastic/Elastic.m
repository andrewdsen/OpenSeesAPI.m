% This command allows the user to construct an ElasticSection. The inclusion of shear deformations 
% is optional.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Elastic_Section
%
% tcl syntax:
% 2D | section Elastic $secTag $E $A $Iz <$G $alphaY>
% 3D | section Elastic $secTag $E $A $Iz $Iy $G $J <$alphaY $alphaZ>
%
% MATLAB syntax:
% 

classdef Elastic < OpenSees
    
    properties
        
        format = '% 0.7f';
        
        % required
        tag = [];   % section tag
        E = [];     % elastic modulus
        A = [];     % cross-sectional area
        Iz = [];    % second moment of area about local z-axis
        
        % optional
        Iy = [];        % second moment of area about local y-axis
        G = [];         % shear modulus
        J = [];         % torsional moment of inertia of section
        alphaY = [];    % shear shape factor along local y-axis
        alphaZ = [];    % shear shape factor along local z-axis

    end
    
    methods
        
        function obj = Elastic(tag,E,A,Iz,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'E');
            addRequired(p,'A');
            addRequired(p,'Iz');
            addOptional(p,'Iy',obj.Iy);
            addOptional(p,'G',obj.G);
            addOptional(p,'J',obj.J);
            addOptional(p,'alphaY',obj.alphaY);
            addOptional(p,'alphaZ',obj.alphaZ);
            parse(p,tag,E,A,Iz,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.E = E;
            obj.A = A;
            obj.Iz = Iz;
            
            % command line open
            obj.cmdLine = ['section Elastic ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.E, obj.format) ' ' ...
                           num2str(obj.A, obj.format) ' ' ...
                           num2str(obj.Iz, obj.format)];
                       
            if any(ismember(p.UsingDefaults,'Iy')) == 0
                
                % store variable
                obj.Iy = p.Results.Iy;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.Iy, obj.format)];
                
            end
                       
            if any(ismember(p.UsingDefaults,'G')) == 0
                
                % store variable
                obj.G = p.Results.G;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.G, obj.format)];
                
            end
                       
            if any(ismember(p.UsingDefaults,'J')) == 0
                
                % store variable
                obj.J = p.Results.J;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.J, obj.format)];
                
            end 
            
                       
            if any(ismember(p.UsingDefaults,'alphaY')) == 0
                
                % store variable
                obj.alphaY = p.Results.alphaY;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.alphaY, obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'alphaZ')) == 0
                
                % store variable
                obj.alphaZ = p.Results.alphaZ;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.alphaZ, obj.format)];
                
            end
            
        end
        
    end
    
end