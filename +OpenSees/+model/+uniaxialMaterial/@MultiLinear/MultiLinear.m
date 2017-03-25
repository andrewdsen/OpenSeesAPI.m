classdef MultiLinear < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '% 0.9f';
   
        % required
        u = [];     % array of strains or deformations
        f = [];     % array of stresses or forces
        
    end
    
    methods
        
        function obj = MultiLinear(tag,u,f)
           
            % store variables
            obj.tag = tag;
            obj.u = u;
            obj.f = f;
            
            % check that number of objects in u equals number of objects in f
            if length(obj.u) ~= length(obj.f)
                error('number of elements in u and f must be the same');
            else
                n = length(obj.u);
            end
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial MultiLinear ' num2str(obj.tag)];
            for ii = 1:n
                obj.cmdLine = [obj.cmdLine ' ' num2str(obj.u(ii),obj.format) ' ' num2str(obj.f(ii),obj.format)];
            end
            
        end
        
    end
    
end