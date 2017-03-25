classdef MultipleSupport < OpenSees
    
    properties
        
        tag                 % pattern tag
        groundMotion        % command to generate a ground motion
        imposedMotion = []; % command to generate an imposed motion
        
    end
   
    methods
       
        function obj = MultipleSupport(tag,groundMotion,imposedMotion)
            
            % store variables
            obj.tag = tag;
            obj.groundMotion = groundMotion;
            obj.imposedMotion = imposedMotion;
            
            % command line open
            obj.cmdLine = ['pattern MultipleSupport ' ...
                           num2str(obj.tag) ' {\n' ...
                           '\t' obj.groundMotion.cmdLine '\n'];

            % command line add
            for ii = 1:size(obj.imposedMotion,1)
                
                obj.cmdLine = [obj.cmdLine obj.imposedMotion(ii).cmdLine '\n'];
                
            end
            
            % command line close
            obj.cmdLine = [obj.cmdLine '};'];
            
        end
        
    end
    
end