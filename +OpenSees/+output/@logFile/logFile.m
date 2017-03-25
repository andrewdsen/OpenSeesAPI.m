classdef logFile < OpenSees
    
    properties
        
        fileName = [];  % string with name of log file
        
    end
    
    methods
    
        function obj = logFile(fileName)
            
            % store variables
            obj.fileName = fileName;
            
            % command line open
            obj.cmdLine = ['logFile ' obj.fileName];
            
        end
        
    end
    
end
    