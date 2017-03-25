classdef eigen < OpenSees
    
properties

    n_modes

end

properties (Access = private)
    
    format = ' %0.8f';
    large_format = ' %0.15f';
    
end

    methods

        function obj = eigen(n_modes)

            % store variables
            obj.n_modes = n_modes;
            
            % command line open
            obj.cmdLine = [obj.cmdLine '\n' ...
                           'set pi [expr atan(1.0)*4.0];\n' ...
                           'set eigenvalue [eigen ' num2str(obj.n_modes, '%g') '];\n'];
                       
            for ii = 1:n_modes
                obj.cmdLine = [obj.cmdLine ...
                    'set omega' num2str(ii, '%g') ' [expr pow([lindex $eigenvalue ' num2str(ii-1, '%g') '], 0.5)];\n' ...
                    'puts "T' num2str(ii, '%g') ' = [expr 2.0*$pi/$omega' num2str(ii, '%g') '] s";\n'];
            end

        end

    end

end