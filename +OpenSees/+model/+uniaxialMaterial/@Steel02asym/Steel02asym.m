% This command is used to construct a uniaxial Giuffre-Menegotto-Pinto steel material object with 
% isotropic strain hardening. This has been modified to allow for different yield stresses and
% hardening ratios in positive and negative loading.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Steel02_Material_--_Giuffr%C3%A9-Menegotto-Pinto_Model_with_Isotropic_Strain_Hardening
%
% tcl syntax:
% uniaxialMaterial Steel02asym $matTag $Fyp $Fyn $E $bp $bn $R0 $cR1 $cR2 <$a1 $a2 $a3 $a4 $sigInit>
%
% MATLAB syntax:
% Steel02asym(tag,Fyp,Fyn,E0,bp,bn,R0,CR1,CR2,<a1,a2,a3,a4,sigInit>)


classdef Steel02asym < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '% 0.5f'; % string format
        
        Fyp          % yield stress in positive loading direction
        Fyn          % yield stress in negative loading direction
        E0           % initial elastic tangent
        bp           % strain hardening ratio (Esh/E0) in positive loading direction
        bn           % strain hardening ratio (Esh/E0) in negative loading direction
        R0 = 15;     % parameter (recommended 10 <= R0 <= 20)
        CR1 = 0.925; % parameter (recommended CR1 == 0.925)
        CR2 = 0.15;  % parameter (recommended CR2 = 0.15)
        a1           % isotropic hardening parameter, increase of compression yield envelope as a
                     % proportion of yield strength after a plastic strain of a2*Fy/E0 (optional)
        a2           % isotropic hardening parameter (optional, default a2 == 1.0)
        a3           % isotropic hardening parameter, increase of tension yield envelope as a
                     % proportion of yield stress after a plastic strain of a4*Fy/E0 (optional)
        a4           % isotropic hardening parameter (optional, default a4 == 1.0)
        sigInit      % initial stress value, the strain is calculated from epsP = sigInit/E
        
    end
    
    methods
        
        function obj = Steel02asym(tag,Fyp,Fyn,E0,bp,bn,R0,CR1,CR2,a1,a2,a3,a4,sigInit)
            
            % store variables
            obj.tag = tag;
            obj.Fyp = Fyp;
            obj.Fyn = Fyn;
            obj.E0 = E0;
            obj.bp = bp;
            obj.bn = bn;
            if nargin > 6
                obj.R0 = R0;
                obj.CR1 = CR1;
                obj.CR2 = CR2;
            end
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Steel02asym ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.Fyp,obj.format) ' ' ...
                           num2str(obj.Fyn,obj.format) ' ' ...
                           num2str(obj.E0,obj.format) ' ' ...
                           num2str(obj.bp,obj.format) ' ' ...
                           num2str(obj.bn,obj.format) ' ' ...
                           num2str(obj.R0,obj.format) ' ' ...
                           num2str(obj.CR1,obj.format) ' ' ...
                           num2str(obj.CR2,obj.format)];
                       
            if nargin == 14
                
                % store variables
                obj.a1 = a1;
                obj.a2 = a2;
                obj.a3 = a3;
                obj.a4 = a4;
                obj.sigInit = sigInit;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.a1,obj.format) ' ' ...
                               num2str(obj.a2,obj.format) ' ' ...
                               num2str(obj.a3,obj.format) ' ' ...
                               num2str(obj.a4,obj.format) ' ' ...
                               num2str(obj.sigInit,obj.format)];
                           
            end

        end
        
    end
    
end