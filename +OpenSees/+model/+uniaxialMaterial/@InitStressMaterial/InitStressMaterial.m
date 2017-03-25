classdef InitStressMaterial < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '% 0.9f';
   
        prevMat = [];
        initStress = [];
        
    end
    
    methods
        
        function obj = InitStressMaterial(tag, prevMat, initStress)
           
            % store variables
            obj.tag = tag;
            obj.prevMat = prevMat;
            obj.initStress = initStress;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial InitStressMaterial ' num2str(obj.tag) ' ' ...
                           num2str(obj.prevMat.tag) ' ' ...
                           num2str(obj.initStress, obj.format)];
            
        end
        
    end
    
end