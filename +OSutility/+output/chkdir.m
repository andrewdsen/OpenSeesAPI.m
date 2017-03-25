classdef chkdir < OpenSees
    
properties (Access = private)

    out_folder

end

methods

    function obj = chkdir(out_folder)

        obj.out_folder = out_folder;
        obj.cmdLine = ['file mkdir "' obj.out_folder '"'];

    end

end
    
end