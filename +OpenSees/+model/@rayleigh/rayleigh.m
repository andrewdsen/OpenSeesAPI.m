classdef rayleigh < OpenSees
   
    properties
       
        alphaM = [];        % factor applied to elements or nodes mass matrix
        betaK = [];         % factor applied to elements current stiffness matrix
        betaKinit =[];      % factor applied to elements initial stiffness matrix
        betaKcomm = [];     % factor applied to elements committed stiffness matrix
        
    end
    
    methods
        
        function obj = rayleigh(alphaM, betaK, betaKinit, betaKcomm)
            
            % store variables
            obj.alphaM = alphaM;
            obj.betaK = betaK;
            obj.betaKinit = betaKinit;
            obj.betaKcomm = betaKcomm;
            
            % command line open
            obj.cmdLine = ['rayleigh ' num2str(obj.alphaM) ' ' ...
                           num2str(obj.betaK) ' ' ...
                           num2str(obj.betaKinit) ' ' ...
                           num2str(obj.betaKcomm)];
            
        end
        
    end
    
    
end