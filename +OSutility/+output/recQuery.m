classdef recQuery < OpenSees
    
    properties
        
        % required
        rec = [];   % recorder object to be queries
        
    end
    
    methods
       
        function obj = recQuery(rec)
   
            % store variables
            obj.tempTag = tempTag;
            obj.rec = rec;
            
            % command line open
            obj.cmdLine = ['set tempTag [' obj.rec '];\n' ...
                           'record;\n' ...
                           'remove recorder $tempTag'];
            
        end
        
    end
    
end