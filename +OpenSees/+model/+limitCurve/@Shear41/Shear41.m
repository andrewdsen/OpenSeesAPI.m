classdef Shear41 < OpenSees.model.limitCurve
    
    properties
        
        format = '% 0.5f';
        format_array = ' %0.5f';
        
        % required
        ele = [];
        dofl;
        dofv;
        ndI;
        ndJ;
        fpc;
        fyt;
        Ag;
        rho;
        thetay;
        VColOE;
        Kunload;
        
        % optional      
        
    end
    
    methods
       
        function obj = Shear41(tag, ele, dofl, dofv, ndI, ndJ, fpc, fyt, Ag, rho, thetay, VColOE, Kunload, varargin)
            
%             p = inputParser;
%             addRequired(p, 'ele');
%             addRequired(p, 'dofl');
%             addRequired(p, 'dofv');
%             addRequired(p, 'ndI');
%             addRequired(p, 'ndJ');
%             addRequired(p, 'fpc');
%             addRequired(p, 'fyt');
%             addRequired(p, 'Ag');
%             addRequired(p, 'rho');
%             addRequired(p, 'thetay');
%             addRequired(p, 'VColOE');
%             addRequired(p, 'Kunload');
%             parse(p, tag, ele, dofl, dofv, ndI, ndJ, fpc, fyt, Ag, rho, thetay, VColOE, Kunload, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.type = 2;
            obj.ele = ele;
            obj.dofl = dofl;
            obj.dofv = dofv;
            obj.ndI = ndI;
            obj.ndJ = ndJ;
            obj.fpc = fpc;
            obj.fyt = fyt;
            obj.Ag = Ag;
            obj.rho = rho;
            obj.thetay = thetay;
            obj.VColOE = VColOE;
            obj.Kunload = Kunload;
            
            % command line open
            obj.cmdLine = ['limitCurve Shear41 ' num2str(obj.tag) ' ' ...
                           num2str(obj.ele.tag) ' ' ...
                           num2str(obj.dofl) ' ' ...
                           num2str(obj.dofv) ' ' ...
                           num2str(obj.ndI.tag) ' ' ...
                           num2str(obj.ndJ.tag) ' ' ...
                           num2str(obj.fpc, obj.format) ' ' ...
                           num2str(obj.fyt, obj.format) ' ' ...
                           num2str(obj.Ag, obj.format) ' ' ...
                           num2str(obj.rho, obj.format) ' ' ...
                           num2str(obj.thetay, obj.format) ' ' ...
                           num2str(obj.VColOE, obj.format) ' ' ...
                           num2str(obj.Kunload, obj.format)];
                       
        end
        
        function rewrite(obj)
           
            obj.cmdLine = ['limitCurve Shear41 ' num2str(obj.tag) ' ' ...
                           num2str(obj.ele.tag) ' ' ...
                           num2str(obj.dofl) ' ' ...
                           num2str(obj.dofv) ' ' ...
                           num2str(obj.ndI.tag) ' ' ...
                           num2str(obj.ndJ.tag) ' ' ...
                           num2str(obj.fpc, obj.format) ' ' ...
                           num2str(obj.fyt, obj.format) ' ' ...
                           num2str(obj.Ag, obj.format) ' ' ...
                           num2str(obj.rho, obj.format) ' ' ...
                           num2str(obj.thetay, obj.format) ' ' ...
                           num2str(obj.VColOE, obj.format) ' ' ...
                           num2str(obj.Kunload, obj.format)];
            
        end
        
    end
    
end
        