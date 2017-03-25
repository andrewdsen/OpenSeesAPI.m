classdef push1 < OpenSees
   
    properties
        
        ctrlNode    % control node
        ctrldof     % control dof
        target      % displacement target
        incr        % target displacement increment (absolute)
        tol         % convergence tolerance
        maxIter     % maximum number of iterations for convergence
                
    end
    
    methods
        
        function obj = push1(ctrlNode,ctrldof,target,incr,tol,maxIter)
           
            obj.ctrlNode = ctrlNode;
            obj.ctrldof = ctrldof;
            obj.target = target;
            obj.incr = incr;
            obj.tol = tol;
            obj.maxIter = maxIter;
            
            numSteps = round(abs(obj.target/obj.incr)); % number of steps in analysis
            actualIncr = obj.target/numSteps;           % actual displacement increment
            
            temp = database('','','');
            temp.script = [];
            
            temp.addCmd( OpenSees.analysis.integrator.DisplacementControl(obj.ctrlNode,obj.ctrldof,actualIncr) );
            temp.addCmd( OpenSees.analysis.constraints.Plain );
            temp.addCmd( OpenSees.analysis.numberer.RCM );
            temp.addCmd( OpenSees.analysis.system.BandGeneral );
            
            temp.addCmd( OpenSees.analysis.test.NormDispIncr(obj.tol,obj.maxIter) );
            temp.addCmd( OpenSees.analysis.algorithm.Newton );
            temp.addCmd( OpenSees.analysis.analysisType.Static );
            temp.addCmd( OpenSees.analysis.analyze(numSteps) );
            
            obj.cmdLine = temp.script(1:end-3); % omit final new line
            
        end
        
    end
    
end