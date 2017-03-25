% This command is used to construct a convergence test which uses the norm of the left hand side 
% solution vector of the matrix equation to determine if convergence has been reached. What the 
% solution vector of the matrix equation is depends on integrator and constraint handler chosen. 
% Usually, though not always, it is equal to the displacement increments that are to be applied to 
% the model.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Norm_Displacement_Increment_Test
%
% tcl syntax:
% test NormDispIncr $tol $iter <$pFlag> <$nType>

classdef NormDispIncr < OpenSees
    
    properties
        
        format = '%0.9f'; % string format
        
        tol        % tolerance criteria used to check convergence
        iter       % maximum number of iterations to check before returning failure criterion
        pFlag = 0; % optional print flag:
                   % | 0 print nothing (default)
                   % | 1 print information on norms each time test() is invoked
                   % | 2 print information on norms and number of iterations at end of successful
                   %     test
                   % | 4 at each step, print the norms and also the DU and R(U) vectors
                   % | 5 if failure to converge at end of iter, print an error message but return a
                   % |   successful test
        nType = 2; % optional type of norm:
                   % | 0 max-norm
                   % | 1 1-norm
                   % | 2 2-norm (defualt)
                   
    end
    
    methods
        
        function obj = NormDispIncr(tol,iter,pFlag,nType)
            
            % store variables
            obj.tol = tol;
            obj.iter = iter;
            
            if nargin > 2
                
                % store variables
                obj.pFlag = pFlag;
                
            end
            
            if nargin > 3
                
                % store variables
                obj.nType = nType;
                
            end
            
            % command line open
            obj.cmdLine = ['test NormDispIncr ' ... 
                           num2str(obj.tol,obj.format) ' ' ...
                           num2str(obj.iter) ' ' ...
                           num2str(obj.pFlag) ' ' ...
                           num2str(obj.nType)];
                       
        end
        
    end
    
end

