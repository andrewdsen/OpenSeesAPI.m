% This command is used to construct a uniaxial Kent-Scott-Park concrete material object with
% degraded linear unloading/reloading stiffness according to the work of Karsan-Jirsa and no tensile
% strength. 
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Concrete01_Material_--_Zero_Tensile_Strength
%
% tcl syntax:
% uniaxialMaterial Concrete01 $matTag $fpc $epsc0 $fpcu $epsU
%
% MATLAB syntax:
% Concrete01(tag,fpc,epsc0,fpcu,epsU)

classdef Concrete01 < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.5f';   % string format
        
        % required
        fpc = [];       % concrete compressive strength at 28  days (compression is negative)
        epsc0 = [];     % concrete strain at maximum strength
        fpcu = [];      % concrete crushing strength
        epsU = [];      % concrete strain at crushing
       
        % output
        G = [];         % shear modulus
        
    end
    
    methods
        
        function obj = Concrete01(tag,fpc,epsc0,fpcu,epsU)
            
            % store variables
            obj.tag = tag;
            obj.fpc = -fpc;
            obj.epsc0 = -epsc0;
            obj.fpcu = -fpcu;
            obj.epsU = -epsU;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Concrete01 ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.fpc,obj.format) ' ' ...
                           num2str(obj.epsc0,obj.format) ' ' ...
                           num2str(obj.fpcu,obj.format) ' ' ...
                           num2str(obj.epsU,obj.format)];
            
            E = 2*obj.fpc/obj.epsc0;
            obj.G = E/(2*(1 + 0.2));
                       
        end
        
    end
    
end