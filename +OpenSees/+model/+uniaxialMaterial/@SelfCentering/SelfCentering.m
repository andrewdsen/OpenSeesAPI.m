classdef SelfCentering < OpenSees.model.uniaxialMaterial
   
properties
   
    format = '% 0.5f';
    
    k1
    k2
    sigAct
    beta
    epsSlip = 0
    epsBear = 0
    rBear = 0
    
end

methods
    
    function obj = SelfCentering(tag, k1, k2, sigAct, beta, varargin)
       
        p = inputParser;
        addRequired(p, 'tag');
        addRequired(p, 'k1');
        addRequired(p, 'k2');
        addRequired(p, 'sigAct');
        addRequired(p, 'beta');
        addOptional(p, 'epsSlip', obj.epsSlip);
        addOptional(p, 'epsBear', obj.epsBear);
        addOptional(p, 'rBear', obj.rBear);
        parse(p, tag, k1, k2, sigAct, beta, varargin{:});

        % store variables
        obj.tag = tag;
        obj.k1 = k1;
        obj.k2 = k2;
        obj.sigAct = sigAct;
        obj.beta = beta;
        
         if any(ismember(p.UsingDefaults, 'epsSlip')) == 0
             obj.epsSlip = p.Results.epsSlip;
         end
         if any(ismember(p.UsingDefaults, 'epsBear')) == 0
             obj.epsBear = p.Results.epsBear;
         end
         if any(ismember(p.UsingDefaults, 'rBear')) == 0
             obj.rBear = p.Results.rBear;
         end
         
         obj.cmdLine = ['uniaxialMaterial SelfCentering ' num2str(obj.tag) ' ' ...
                        num2str(obj.k1, obj.format) ' ' ...
                        num2str(obj.k2, obj.format) ' ' ...
                        num2str(obj.sigAct, obj.format) ' ' ...
                        num2str(obj.beta, obj.format) ' ' ...
                        num2str(obj.epsSlip, obj.format) ' ' ...
                        num2str(obj.epsBear, obj.format) ' ' ...
                        num2str(obj.rBear, obj.format)];
        
    end
    
end
    
end