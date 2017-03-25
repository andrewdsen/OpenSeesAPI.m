% Creates the Concrete02 uniaxial material. The initial slope of the model is (2*$fpc/$epsc0).
% 
% Ref: http://opensees.berkeley.edu/wiki/index.php/Concrete02_Material_--_Linear_Tension_Softening
%
% tcl syntax:
% uniaxialMaterial Concrete02 $matTag $fpc $epsc0 $fpcu $epsU $lambda $ft $Ets
%
% MATLAB syntax:
% Concrete02(tag,fpc,epsc0,fpcu,epsU,lambda,ft,Ets)

classdef Concrete02 < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '%0.5f';   % string format
        
        fpc = [];       % concrete compressive strength at 28  days (compression is negative)
        epsc0 = [];     % concrete strain at maximum strength
        fpcu = [];      % concrete crushing strength
        epsU = [];      % concrete strain at crushing
        lambda = [];    % ratio between unloading slope at epsU and initial slope
        ft = [];        % tensile strength
        Ets = [];       % tension softening stiffness (absolute value) (slope of the linear tension softening branch)
        
    end
    
    methods
        
        function obj = Concrete02(tag,fpc,epsc0,fpcu,epsU,lambda,ft,Ets)
            
            % store variables
            obj.tag = tag;
            obj.fpc = fpc;
            obj.epsc0 = epsc0;
            obj.fpcu = fpcu;
            obj.epsU = epsU;
            obj.lambda = lambda;
            obj.ft = ft;
            obj.Ets = Ets;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Concrete02 ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.fpc,obj.format) ' ' ...
                           num2str(obj.epsc0,obj.format) ' ' ...
                           num2str(obj.fpcu,obj.format) ' ' ...
                           num2str(obj.epsU,obj.format) ' ' ...
                           num2str(obj.lambda,obj.format) ' ' ...
                           num2str(obj.ft,obj.format) ' ' ...
                           num2str(obj.Ets,obj.format)];
            
        end
        
    end
    
end