classdef InitStrainMaterial < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '% 0.9f';
   
        prevMat = [];
        initStrain = [];
        
    end
    
    methods
        
        function obj = InitStrainMaterial(tag, prevMat, initStrain)
           
            % store variables
            obj.tag = tag;
            obj.prevMat = prevMat;
            obj.initStrain = initStrain;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial InitStrainMaterial ' num2str(obj.tag) ' ' ...
                           num2str(obj.prevMat.tag) ' ' ...
                           num2str(obj.initStrain, obj.format)];
            
        end
        
    end
    
end