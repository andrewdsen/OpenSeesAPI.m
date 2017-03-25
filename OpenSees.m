classdef OpenSees < handle & matlab.mixin.Heterogeneous
    
    properties
        
        cmdLine = ''; % command line without options
        options = ''; % optional additions to command line (e.g., if there are options that are
                      % unsupported by the API)
        notes = '';   % optional notes (comments)
        
    end
    
end