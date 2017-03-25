% This command allows the user to construct a WFSection2d object, which is an encapsulated fiber 
% representation of a wide flange steel section appropriate for plane frame analysis.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Wide_Flange_Section
%
% tcl syntax:
% section WFSection2d $secTag $matTag $d $tw $bf $tf $Nfw $Nff
%
% MATLAB syntax:
% WFSection2d(secTag,matTag,d,tw,bf,tf,nfw,nff)

classdef WFSection2d < OpenSees
    
    properties
        
        format = '%0.5f '; % string format
        
        tag     % unique section tag
        mat     % uniaxialMaterial object assigned to each fiber
        d       % section depth (see AISC Manual)
        tw      % web thickness (see AISC Manual)
        bf      % flange width (see AISC Manual)
        tf      % flange thickness (see AISC Manual)
        nfw     % number of fibers in the web
        nff     % number of fibers in each flange
        
    end
    
    methods
        
        function obj = WFSection2d(tag,mat,d,tw,bf,tf,nfw,nff)
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.d = d;
            obj.tw = tw;
            obj.bf = bf;
            obj.tf = tf;
            obj.nfw = nfw;
            obj.nff = nff;
            
            % command line open
            obj.cmdLine = ['section WFSection2d ' ...
                           num2str(obj.tag) ' ' ...
                           num2str(obj.mat.tag) ' ' ...
                           num2str(obj.d,obj.format) ' ' ...
                           num2str(obj.tw,obj.format) ' ' ...
                           num2str(obj.bf,obj.format) ' ' ...
                           num2str(obj.tf,obj.format) ' ' ...
                           num2str(obj.nfw) ' ' ...
                           num2str(obj.nff)];
            
        end

    end
    
end