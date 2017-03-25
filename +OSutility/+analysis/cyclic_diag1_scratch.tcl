set ctrl_node_analysis $ctrl_node_analysis_name;
set ctrl_dof_analysis $ctrl_dof_analysis_name;
set ctrl_node_i $ctrl_node_i_name;
set ctrl_node_j $ctrl_node_j_name;
set ctrl_dof_1 $ctrl_dof_1_name;
set ctrl_dof_2 $ctrl_dof_2_name;
set ctrl_dof_index_1 [expr $ctrl_dof_1 - 1];
set ctrl_dof_index_2 [expr $ctrl_dof_2 - 1];
set init_node_i [nodeCoord $ctrl_node_i];
set init_node_j [nodeCoord $ctrl_node_j];
set init_dist_1 [expr [lindex $init_node_j 0] - [lindex $init_node_i 0]];
set init_dist_2 [expr [lindex $init_node_j 1] - [lindex $init_node_i 1]];
set init_length [expr hypot($init_dist_1, $init_dist_2)];
set targ_incr $targ_incr_name;
set targ_tol $targ_tol_name;
set max_iter $max_iter_name;
foreach targ_disp { ... } {
   constraints Plain;
   numberer RCM;
   system Mumps -ICNTL 100;
   set disp_node_i [nodeDisp $ctrl_node_i];
   set disp_node_j [nodeDisp $ctrl_node_j];
   set ctrl_disp [expr hypot($init_dist_1 + [lindex $disp_node_i $ctrl_dof_index_1] + [lindex $disp_node_j $ctrl_dof_index_1], $init_dist_2 + [lindex $disp_node_i $ctrl_dof_index_2] + [lindex $disp_node_j $ctrl_dof_index_2]) - $init_length];
   set travel 0.0;
   set rel_disp [expr $targ_disp - $ctrl_disp];
   if {$rel_disp > 0} {
      set sgn 1.0;
   } else {
      set sgn -1.0;
   };
   set incr [expr $sgn*$targ_incr];
   puts "\nexcursion: $targ_disp | increment: $incr\n";
   while {[expr abs($travel)] < [expr abs($rel_disp)]} {
      test NormDispIncr $targ_tol $max_iter;
      algorithm Newton;
      integrator DisplacementControl $ctrl_node_analysis $ctrl_dof_analysis $incr;
      analysis Static;
      set ok [analyze 1];
      if {$ok != 0} {
         set print_disp [expr int($travel*100.0)/100.0];
         puts "\t> at $print_disp";
         set temp_incr $incr;
         set denom 2.0;
         set counter 0;
         set temp_tol $targ_tol;
         while {$ok != 0} {
            incr counter;
            if {$counter == 1} {
               algorithm KrylovNewton -maxDim 6;
            } elseif {$counter == 8} {
               test NormDispIncr [expr $targ_tol*10.0] $max_iter;
            } elseif {$counter == 16} {
               exit;
            };
            set temp_incr [expr $temp_incr/$denom];
            set puts "\t\t> trying increment: $temp_incr";
            integrator DisplacementControl $ctrl_node_analysis $ctrl_dof_analysis $temp_incr;
            set ok [analyze 1];
         };
      };
      set disp_node_i [nodeDisp $ctrl_node_i];
      set disp_node_j [nodeDisp $ctrl_node_j];
      set diag_incr [expr hypot($init_dist_1 + [lindex $disp_node_i $ctrl_dof_index_1] + [lindex $disp_node_j $ctrl_dof_index_1], $init_dist_2 + [lindex $disp_node_i $ctrl_dof_index_2] + [lindex $disp_node_j $ctrl_dof_index_2]) - $init_length - $ctrl_disp];
      set travel [expr $travel + $diag_incr];
   };
};
