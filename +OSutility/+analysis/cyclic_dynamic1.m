classdef cyclic_dynamic1 < OpenSees
   
    properties
        
        format = ' %0.9f';
        
        dt          % target time-step increment
        min_dt      % minimum time-step increment
        time        % total loading time
        tol         % convergence tolerance
        maxIter     % maximum number of iterations for convergence
        
    end
    
    methods
        
        function obj = cyclic_dynamic1(dt,min_dt,time,tol,maxIter)
           
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
                           '\t'     'algorithm Newton;\n' ...
                           '\t'     'set temp_dt $targ_dt;\n' ...
                           '\t'     'set ok [analyze 1 $temp_dt];\n' ...
                           '\t'     'while {$ok != 0} {\n' ...
                           '\t\t'       'algorithm KrylovNewton -maxDim 6;\n' ...
                           '\t\t'       'puts "\n\t> analysis failed at time $cur_time, trying KrylovNewton\n";\n' ...
                           '\t\t'       'if {$temp_dt < $min_dt} {\n' ...
                           '\t\t\t'         'puts "> analysis failed at time $cur_time after exceeding minimum dt, exiting";\n' ...
                           '\t\t\t'         'wipe;\n' ...
                           '\t\t\t'         'exit;\n' ...
                           '\t\t'       '};\n' ...
                           '\t\t'       'set temp_dt [expr $temp_dt/10.0];\n' ...
                           '\t\t'       'puts "> analysis failed at time $cur_time, trying dt $temp_dt";\n' ...
                           '\t\t'       'set ok [analyze 1 $temp_dt];\n' ...
                           '\t'     '};\n' ...
                           '\t'     'set cur_time [expr $cur_time + $temp_dt];\n' ...
                           '}'];
                       
        end
        
    end
    
end