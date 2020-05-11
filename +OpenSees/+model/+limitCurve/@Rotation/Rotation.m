classdef Rotation < OpenSees.model.limitCurve
    
    properties
        
        format = '% 0.6f';
        format_array = ' %0.6f';
        format_tag = ' %0.0f';
        
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
        adda;
        addb;
        addc;
        VyE;
        fyl;
        rhol;
        eleRem = [];
        
    end
    
    methods
       
        function obj = Rotation(tag, ele, dofl, dofv, ndI, ndJ, fpc, fyt, Ag, rho, thetay, VColOE, Kunload, varargin)
            
            p = inputParser;
            addRequired(p, 'ele');
            addRequired(p, 'dofl');
            addRequired(p, 'dofv');
            addRequired(p, 'ndI');
            addRequired(p, 'ndJ');
            addRequired(p, 'fpc');
            addRequired(p, 'fyt');
            addRequired(p, 'Ag');
            addRequired(p, 'rho');
            addRequired(p, 'thetay');
            addRequired(p, 'VColOE');
            addRequired(p, 'Kunload');
            addOptional(p, 'adda', obj.adda);
            addOptional(p, 'addb', obj.addb);
            addOptional(p, 'addc', obj.addc);
            addOptional(p, 'VyE', obj.VyE);
            addOptional(p, 'eleRem', obj.eleRem);
            addOptional(p, 'fyl', obj.fyl);
            addOptional(p, 'rhol', obj.rhol);
            parse(p, tag, ele, dofl, dofv, ndI, ndJ, fpc, fyt, Ag, rho, thetay, VColOE, Kunload, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.type = 3;
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
            obj.cmdLine = ['limitCurve Rotation ' num2str(obj.tag) ' ' ...
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
                       
            if any(ismember(p.UsingDefaults, 'adda')) == 0
                obj.adda = p.Results.adda;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-adda ' num2str(obj.adda, obj.format)];
            end
            if any(ismember(p.UsingDefaults, 'addb')) == 0
                obj.addb = p.Results.addb;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-addb ' num2str(obj.addb, obj.format)];
            end
            if any(ismember(p.UsingDefaults, 'addc')) == 0
                obj.addc = p.Results.addc;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-addc ' num2str(obj.addc, obj.format)];
            end
            if any(ismember(p.UsingDefaults, 'VyE')) == 0
                obj.VyE = p.Results.VyE;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-VyE ' num2str(obj.VyE, obj.format)];
            end
            if any(ismember(p.UsingDefaults, 'eleRem')) == 0
                obj.eleRem = p.Results.eleRem;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-eleRemTag ' num2str(obj.eleRem.tag, obj.format_tag)];
            end
            if any(ismember(p.UsingDefaults, 'fyl')) == 0
                obj.fyl = p.Results.fyl;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-fyl ' num2str(obj.fyl, obj.format)];
            end
            if any(ismember(p.UsingDefaults, 'rhol')) == 0
                obj.rhol = p.Results.rhol;
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-rhol ' num2str(obj.rhol, obj.format)];
            end

        end
        
        function rewrite(obj)
           
            obj.cmdLine = ['limitCurve Rotation ' num2str(obj.tag) ' ' ...
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
                       
            if obj.adda ~= 0
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-adda ' num2str(obj.adda, obj.format)];
            end
            if obj.addb ~= 0
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-addb ' num2str(obj.addb, obj.format)];
            end
            if obj.addc ~= 0
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-addc ' num2str(obj.addc, obj.format)];
            end
            if ~isempty(obj.VyE)
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-VyE ' num2str(obj.VyE, obj.format)];
            end
            if ~isempty(obj.eleRem)
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-eleRemTag ' num2str(obj.eleRem.tag, obj.format_tag)];
            end
            if ~isempty(obj.fyl)
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-fyl ' num2str(obj.fyl, obj.format)];
            end
            if ~isempty(obj.rhol)
                obj.cmdLine = [obj.cmdLine ' ' ...
                    '-rhol ' num2str(obj.rhol, obj.format)];
            end
        end
        
    end
    
end
        