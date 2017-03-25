classdef input_accelerogram_damping < OpenSees

    properties

        format = ' %0.11f';

        gm          % ground motion metadata and time history (input accelerogram)
        g           % gravitational acceleration
        dof         % degree of freedom of acceleration
        dt          % analysis time step
        min_dt      % minimum analysis time step
        free_time   % duration of free vibration after ground motion
        tol         % convergence tolerance
        max_iter    % maximum number of interations for convergence
        zeta        % damping ratio
        mode_i      % first mode for proportional damping
        mode_j      % second mode for proportional damping
        node_damp   % list of nodes for damping assignment
        ele_damp    % list of elements for damping assignment

    end

    methods

        function obj = input_accelerogram_damping(gm, g, dof, dt, min_dt, free_time, tol, max_iter, zeta, mode_i, mode_j, node_damp, ele_damp)

            % store variables
            obj.gm = gm;
            obj.g = g;
            obj.dof = dof;
            obj.dt = dt;
            obj.min_dt = min_dt;
            obj.free_time = free_time;
            obj.tol = tol;
            obj.max_iter = max_iter;
            obj.zeta = zeta;
            obj.mode_i = mode_i;
            obj.mode_j = mode_j;
            obj.node_damp = node_damp;
            obj.ele_damp = ele_damp;

            history_appended = vertcat(obj.gm.history*g, zeros(obj.free_time/obj.gm.dt, 1)).';
            n_total_steps = ceil(length(history_appended)*obj.gm.dt/obj.dt);

            obj.cmdLine = [obj.cmdLine '\n' ...
                           'set ts_tag 2;\n' ...
                           'timeSeries Path $ts_tag -dt ' num2str(obj.gm.dt, obj.format) ' -values {' num2str(history_appended, obj.format) '} -prependZero;\n' ...
                           'pattern UniformExcitation 2 ' num2str(obj.dof) ' -accel $ts_tag\n' ...
                           'constraints Plain;\n' ...
                           'numberer RCM;\n' ...
                           'system Umfpack;\n' ...
                           'set conv_tol ' num2str(obj.tol, obj.format) ';\n' ...
                           'set max_iter ' num2str(obj.max_iter, '%g') ';\n' ...
                           'test NormDispIncr $conv_tol $max_iter;\n' ...
                           'algorithm Newton;\n' ...
                           'integrator Newmark 0.5 0.25;\n' ...
                           'analysis Transient;\n' ...
                           'set dt ' num2str(obj.dt, obj.format) ';\n' ...
                           'set min_dt ' num2str(obj.min_dt, obj.format) ';\n' ...
                           'set n_steps ' num2str(n_total_steps) ';\n' ...
                           'set cur_step 1;\n' ...
                           'set div 10.0;\n' ...
                           'set tol 1.0e-8;\n' ...
                           'while {$cur_step < $n_steps} {\n' ...
                           '\t'     'set eigenvalue [eigen ' num2str(obj.mode_j, '%g') '];\n' ...
                           '\t'     'if {[lindex $eigenvalue 0] > 0} {\n' ...
                           '\t\t'       'set omega1 [expr pow([lindex $eigenvalue ' num2str(obj.mode_i-1, '%g') '], 0.5)];\n' ...
                           '\t\t'       'set omega2 [expr pow([lindex $eigenvalue ' num2str(obj.mode_j-1, '%g') '], 0.5)];\n' ...
                           '\t\t'       'set beta [expr 2.0*' num2str(obj.zeta, obj.format) '/($omega1 + $omega2)];\n' ...
                           '\t\t'       'set alpha [expr $omega1*$omega2*$beta];\n' ...
                           '\t\t'       'region 1 -node ' num2str([obj.node_damp.tag], ' %0g') ' -rayleigh $alpha 0.0 0.0 0.0;\n' ...
                           '\t\t'       'region 2 -ele ' num2str([obj.ele_damp.tag], ' %0g') ' -rayleigh $alpha $beta 0.0 0.0;\n' ...
                           '\t\t'       'test NormDispIncr $conv_tol $max_iter;\n' ...
                           '\t\t'       'algorithm Newton;\n' ...
                           '\t\t'       'set ok [analyze 1 $dt];\n' ...
                           '\t'     '} else {\n' ...
                           '\t\t'       'puts "\n> negative eigenvalues at step $cur_step";\n' ...
                           '\t\t'       'set ok -1;\n' ...
                           '\t'     '};\n' ...
                           '\t'     'if {$ok != 0} {\n' ...
                           '\t\t'       'set dt_temp [expr $dt];\n' ...
                           '\t\t'       'puts "\n\t> analysis failed to converge at step $cur_step";\n' ...
                           '\t\t'       'puts "\t\t> trying KrylovNewton";\n' ...
                           '\t\t'       'algorithm KrylovNewton -maxDim 6;\n' ...
                           '\t\t'       'set ok [analyze 1 $dt];\n' ...
                           '\t\t'       'if {$ok != 0} {\n' ...
                           '\t\t\t'         'set t 0.0;\n' ...
                           '\t\t\t'         'set mini_t 0.0;\n' ...
                           '\t\t\t'         'set dt_temp [expr round($dt/$div/$tol)*$tol];\n' ...
                           '\t\t\t'         'set mini_dt_temp 0.0;\n' ...
                           '\t\t\t'         'set flag1 0;\n' ...
                           '\t\t\t'         'set flag2 0;\n' ...
                           '\t\t\t'         'set flag3 0;\n' ...
                           '\t\t\t'         'while {$t < $dt} {\n' ...
                           '\t\t\t\t'           'if {$dt_temp <= [expr $dt/pow($div, 2)] && $flag1 == 0} {\n' ...
                           '\t\t\t\t\t'             'set flag1 -1;\n' ...
                           '\t\t\t\t\t'             'test NormDispIncr $conv_tol [expr $max_iter + 100];\n' ...
                           '\t\t\t\t'           '} elseif {$dt_temp <= [expr $dt/pow($div, 4)] && $flag2 == 0} {\n' ...
                           '\t\t\t\t\t'             'set flag2 -1;\n' ...
                           '\t\t\t\t\t'             'test NormDispIncr $conv_tol [expr $max_iter + 200];\n' ...
                           '\t\t\t\t\t'             'algorithm KrylovNewton -iterate initial -increment current -maxDim 6;\n' ...
                           '\t\t\t\t'           '} elseif {$dt_temp <= [expr $dt/pow($div, 6)] && $flag3 == 0} {\n' ...
                           '\t\t\t\t\t'             'set flag3 -1;\n' ...
                           '\t\t\t\t'           '};\n' ...
                           '\t\t\t\t'           'if {$dt_temp < $min_dt} {\n' ...
                           '\t\t\t\t\t'             'puts "\n<< model did not converge (reason: time step less than $min_dt)";\n' ...
                           '\t\t\t\t\t'             'puts "<< exiting safely\n";\n' ...
                           '\t\t\t\t\t'             'wipe;\n' ...
                           '\t\t\t\t\t'             'exit;\n' ...
                           '\t\t\t\t'           '};\n' ...
                           '\t\t\t\t'           'set ok [analyze 1 $dt_temp];\n' ...
                           '\t\t\t\t'           'if {$ok == 0} {\n' ...
                           '\t\t\t\t\t'             'set t [expr round(($t + $dt_temp)/$tol)*$tol];\n' ...
                           '\t\t\t\t\t'             'set mini_t [expr round(($mini_t + $dt_temp)/$tol)*$tol];\n' ...
                           '\t\t\t\t\t'             'if {$mini_t >= $mini_dt_temp} {set dt_temp [expr round($dt_temp*$div/$tol)*$tol]};\n' ...
                           '\t\t\t\t\t'             'set eigenvalue [eigen ' num2str(obj.mode_j, '%g') '];\n' ...
                           '\t\t\t\t\t'             'if {[lindex $eigenvalue 0] > 0} {\n' ...
                           '\t\t\t\t\t\t'               'set omega1 [expr pow([lindex $eigenvalue ' num2str(obj.mode_i-1, '%g') '], 0.5)];\n' ...
                           '\t\t\t\t\t\t'               'set omega2 [expr pow([lindex $eigenvalue ' num2str(obj.mode_j-1, '%g') '], 0.5)];\n' ...
                           '\t\t\t\t\t\t'               'set beta [expr 2.0*' num2str(obj.zeta, obj.format) '/($omega1 + $omega2)];\n' ...
                           '\t\t\t\t\t\t'               'set alpha [expr $omega1*$omega2*$beta];\n' ...
                           '\t\t\t\t\t\t'               'region 1 -node ' num2str([obj.node_damp.tag], ' %0g') ' -rayleigh $alpha 0.0 0.0 0.0;\n' ...
                           '\t\t\t\t\t\t'               'region 2 -ele ' num2str([obj.ele_damp.tag], ' %0g') ' -rayleigh $alpha $beta 0.0 0.0;\n' ...
                           '\t\t\t\t\t'             '};\n' ...
                           '\t\t\t\t\t'         'test NormDispIncr $conv_tol $max_iter;\n' ...
                           '\t\t\t\t\t'         'algorithm KrylovNewton -maxDim 6;\n' ...
                           '\t\t\t\t'           '} else {\n' ...
                           '\t\t\t\t\t'             'set mini_t 0.0;\n' ...
                           '\t\t\t\t\t'             'set mini_dt_temp [expr round($dt_temp/$tol)*$tol];\n' ...
                           '\t\t\t\t\t'             'set dt_temp [expr round($dt_temp/$div/$tol)*$tol];\n' ...
                           '\t\t\t\t'           '};\n' ...
                           '\t\t\t'         '};\n' ...
                           '\t\t'       '};\n' ...
                           '\t'     '};\n' ...
                           '\t'     'if {$cur_step %% 100 == 0} {\n' ...
                           '\t\t'       'puts "\n> step $cur_step complete";\n' ...
                           '\t'     '};\n' ...
                           '\t'     'incr cur_step;\n' ...
                           '}'];

        end

    end

end
