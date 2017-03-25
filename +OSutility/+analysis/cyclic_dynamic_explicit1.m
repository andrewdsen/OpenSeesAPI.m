classdef cyclic_dynamic_explicit1 < OpenSees
   
    properties
        
        format = ' %0.9f';
        
        dt          % target time-step increment
        min_dt      % minimum time-step increment
        time        % total loading time
        tol         % convergence tolerance
        maxIter     % maximum number of iterations for convergence
        
    end
    
    methods
        
        function obj = cyclic_dynamic_explicit1(dt,min_dt,time,tol,maxIter)
           
            % store variables
            obj.dt = dt;
            obj.min_dt = min_dt;
            obj.time = time;
            obj.tol = tol;
            obj.maxIter = maxIter;
                    
            % setup system
%             constraints = OpenSees.analysis.constraints.Plain;
            numberer = OpenSees.analysis.numberer.RCM;
%             system = OpenSees.analysis.system.BandGeneral;
%             test = OpenSees.analysis.test.NormDispIncr(obj.tol,obj.maxIter);
%             algorithm = OpenSees.analysis.algorithm.KyrlovNewton;
%             analysis = OpenSees.analysis.analysisType.Static;
            obj.cmdLine = ['constraints Transformation;\n' ...
                           numberer.cmdLine ';\n' ...
                           'system Mumps;\n'];
%                            test.cmdLine ';\n'];
                      
            % analysis convergence loop
            obj.cmdLine = [obj.cmdLine ...
                           'set targ_dt ' num2str(obj.dt,obj.format) ';\n' ...
                           'set min_dt ' num2str(obj.min_dt,' %0.20f') ';\n' ...
                           'set targ_time ' num2str(obj.time) ';\n' ...
                           'set cur_time 0.0;\n' ...
                           'set maxIter ' num2str(obj.maxIter) ';\n' ...
                           'set tol ' num2str(obj.tol,obj.format) ';\n' ...
                           'test NormDispIncr $tol $maxIter;\n' ...
                           'algorithm Linear;\n' ...
                           'integrator CentralDifference;\n' ...
                           'analysis Transient;\n' ...
                           'while {$cur_time < $targ_time} {\n' ...
                           '\t'     'analyze 1 $targ_dt;\n' ...
                           '\t'     'set cur_time [expr $cur_time + $targ_dt];\n' ...
                           '}'];
                       
        end
        
    end
    
end