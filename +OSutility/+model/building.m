classdef building < handle
    
properties
        
    % metadata
    id          % building identification string
    name        % building name
    author      % author name (person who wrote the script)
    designer    % designer name (person or firm who designed the building)
    code        % design code
    coord       % coordinates of site
    lfrs        % type of LFRS
    load_comb   % load combination reference
    
    % data
    db          % OSAPI database object for building
    elastic = false
    V_des       % design base shear as a proportion of W
    W_des       % effective seismic weight (1.0D)
    W_sub       % effective seismic weight of analyzed subsystem
    n_bays      % number of LFRS bays
    n_stories   % number of stories
    unit_force  % force units
    unit_disp   % displacement units
    g           % gravitational acceleration
    
end

methods
    
    function obj = set_units(obj, unit_force, unit_disp)
        
        obj.unit_force = unit_force;
        obj.unit_disp = unit_disp;
        if (strcmp(obj.unit_disp, 'inches') || ...
            strcmp(obj.unit_disp, 'in'))
            obj.g = 386.09;
        end

    end
    
end

end   