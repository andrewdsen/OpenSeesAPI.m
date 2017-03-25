% This command is used to construct a uniaxialMaterial SteelMPF, which represents the well-known 
% uniaxial constitutive nonlinear hysteretic material model for steel proposed by Menegotto and 
% Pinto (1973), and extended by Filippou et al. (1983) to include isotropic strain hardening 
% effects.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/SteelMPF_-_Menegotto_and_Pinto_(1973)_Model_Extended_by_Filippou_et_al._(1983)
%
% tcl syntax:
% uniaxialMaterial SteelMPF $mattag $fyp $fyn $E0 $bp $bn $R0 $a1 $a2 <$a3 $a4>
%
% MATLAB syntax:
% 

classdef SteelMPF < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.9f';   % string format
        
        % required
        Fyp = [];   % yield strength in tension (positive loading direction)
        Fyn = [];   % yield strength in compression (negative loading direction)
        E0 = [];    % initial tangent modulus
        bp = [];    % strain hardening ratio in tension (positive loading direction)
        bn = [];    % strain hardening ratio in compression (negative loading direction)
        R0 = [];    % initial value of the curvature parameter R (R0 = 20 recommended)
        a1 = [];    % curvature degradation parameter (a1 = 18.5 recommnded)
        a2 = [];    % curvature degradation parameter (a2 = 0.15 or 0.0015 recommended)
        
        % optional
        a3 = 0.01;    % isotropic hardening parameter (default = 0.01)
        a4 = 7.0;    % isotropic hardening parameter (default = 7.0)
        
    end
    
    methods
        
        function obj = SteelMPF(tag,Fyp,Fyn,E0,bp,bn,R0,a1,a2,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'Fyp');
            addRequired(p,'Fyn');
            addRequired(p,'E0');
            addRequired(p,'bp');
            addRequired(p,'bn');
            addRequired(p,'R0');
            addRequired(p,'a1');
            addRequired(p,'a2');
            addOptional(p,'a3',obj.a3);
            addOptional(p,'a4',obj.a4);
            parse(p,tag,Fyp,Fyn,E0,bp,bn,R0,a1,a2,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.Fyp = Fyp;
            obj.Fyn = Fyn;
            obj.E0 = E0;
            obj.bp = bp;
            obj.bn = bn;
            obj.R0 = R0;
            obj.a1 = a1;
            obj.a2 = a2;
            if any(ismember(p.UsingDefaults,'a3')) == 0
                obj.a3 = p.Results.a3;
            end
            if any(ismember(p.UsingDefaults,'a4')) == 0
                obj.a4 = p.Results.a4;
            end
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial SteelMPF ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.Fyp,obj.format) ' ' ...
                           num2str(obj.Fyn,obj.format) ' ' ...
                           num2str(obj.E0,obj.format) ' ' ...
                           num2str(obj.bp,obj.format) ' ' ...
                           num2str(obj.bn,obj.format) ' ' ...
                           num2str(obj.R0,obj.format) ' ' ...
                           num2str(obj.a1,obj.format) ' ' ...
                           num2str(obj.a2,obj.format) ' ' ...
                           num2str(obj.a3,obj.format) ' ' ...
                           num2str(obj.a4,obj.format)];
            
        end
        
    end
    
end