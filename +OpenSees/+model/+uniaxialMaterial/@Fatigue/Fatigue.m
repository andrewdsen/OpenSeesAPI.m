% The fatigue material uses a modified rainflow cycle counting algorithm to accumulate damage in a
% material using Miner’s Rule. Element stress/strain relationships become zero when fatigue life is 
% exhausted.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Fatigue_Material
%
% tcl syntax:
% uniaxialMaterial Fatigue $matTag $tag <-E0 $E0> <-m $m> <-min $min> <-max $max>
%
% MATLAB syntax:
%

classdef Fatigue < OpenSees
    
    properties
        
        format = '%0.9f';
        
        % required
        tag = [];       % new material tag
        origMat = [];   % original material
        
        % optional
        eps0 = [];      % value of strain at which one cycle will cause failure
        m = [];         % slope of Coffin-Manson curve in log-log space
        epsMin = [];       % global minimum value for strain or deformation
        epsMax = [];       % global maximum value for strain or deformation
        
    end
    
    methods
        
        function obj = Fatigue(tag,origMat,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'origMat');
            addOptional(p,'eps0',obj.eps0);
            addOptional(p,'m',obj.m);
            addOptional(p,'epsMin',obj.epsMin);
            addOptional(p,'epsMax',obj.epsMax);
            parse(p,tag,origMat,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.origMat = origMat;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Fatigue ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.origMat.tag)];
                       
            if any(ismember(p.UsingDefaults,'eps0')) == 0
                
                % store variable
                obj.eps0 = p.Results.eps0;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-E0 ' num2str(obj.eps0,obj.format)];
                           
            end
            
            if any(ismember(p.UsingDefaults,'m')) == 0
                
                % store variable
                obj.m = p.Results.m;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-m ' num2str(obj.m,obj.format)];
                           
            end
                       
            if any(ismember(p.UsingDefaults,'epsMin')) == 0
                
                % store variable
                obj.epsMin = p.Results.epsMin;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-min ' num2str(obj.epsMin,obj.format)];
                           
            end
                        
            if any(ismember(p.UsingDefaults,'epsMax')) == 0
                
                % store variable
                obj.epsMax = p.Results.epsMax;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               '-max ' num2str(obj.epsMax,obj.format)];
                           
            end
            
        end
        
    end
    
end