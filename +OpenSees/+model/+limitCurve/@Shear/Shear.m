classdef Shear < OpenSees.model.limitCurve
    
    properties
        
        format = '% 0.5f';
        format_array = ' %0.5f';
        
        % required
        ele = [];
        rho;
        fc;
        b;
        h;
        d;
        Fsw;
        Kdeg;
        Fres;
        defType;
        forType;
        
        % optional
        ndI;
        ndJ;
        dof;
        perpDirn;
        delta;        
        
    end
    
    methods
       
        function obj = Shear(tag, ele, rho, fc, b, h, d, Fsw, Kdeg, Fres, defType, forType, varargin)
            
            p = inputParser;
            addRequired(p, 'ele');
            addRequired(p, 'rho');
            addRequired(p, 'fc');
            addRequired(p, 'b');
            addRequired(p, 'h');
            addRequired(p, 'd');
            addRequired(p, 'Fsw');
            addRequired(p, 'Kdeg');
            addRequired(p, 'Fres');
            addRequired(p, 'defType');
            addRequired(p, 'forType');
            addOptional(p, 'ndI', obj.ndI);
            addOptional(p, 'ndJ', obj.ndJ);
            addOptional(p, 'dof', obj.dof);
            addOptional(p, 'perpDirn', obj.perpDirn);
            addOptional(p, 'delta', obj.delta);
            parse(p, tag, ele, rho, fc, b, h, d, Fsw, Kdeg, Fres, defType, forType, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.type = 2;
            obj.ele = ele;
            obj.rho = rho;
            obj.fc = fc;
            obj.b = b;
            obj.h = h;
            obj.d = d;
            obj.Fsw = Fsw;
            obj.Kdeg = Kdeg;
            obj.Fres = Fres;
            obj.defType = defType;
            obj.forType = forType;
            
            % command line open
            obj.cmdLine = ['limitCurve Shear ' num2str(tag) ' ' ...
                           num2str(obj.ele.tag) ' ' ...
                           num2str(obj.rho, obj.format) ' ' ...
                           num2str(obj.fc, obj.format) ' ' ...
                           num2str(obj.b, obj.format) ' ' ...
                           num2str(obj.h, obj.format) ' ' ...
                           num2str(obj.d, obj.format) ' ' ...
                           num2str(obj.Fsw, obj.format) ' ' ...
                           num2str(obj.Kdeg, obj.format) ' ' ...
                           num2str(obj.Fres, obj.format) ' ' ...
                           num2str(obj.defType) ' ' ...
                           num2str(obj.forType)];
                       
            if any(ismember(p.UsingDefaults,'ndI')) == 0 && ... 
               any(ismember(p.UsingDefaults,'ndJ')) == 0 && ...
               any(ismember(p.UsingDefaults,'dof')) == 0 && ...
               any(ismember(p.UsingDefaults,'perpDirn')) == 0 && ...
               any(ismember(p.UsingDefaults,'delta')) == 0

                % store variables
                obj.ndI = p.Results.ndI;
                obj.ndJ = p.Results.ndJ;
                obj.dof = p.Results.dof;
                obj.perpDirn = p.Results.perpDirn;
                obj.delta = p.Results.delta;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.ndI.tag) ' ' ...
                               num2str(obj.ndJ.tag) ' ' ...
                               num2str(obj.dof) ' ' ...
                               num2str(obj.perpDirn) ' ' ...
                               num2str(obj.delta, obj.format)];

            end
                       
        end
        
        function rewrite(obj)
           
            obj.cmdLine = ['limitCurve Shear ' num2str(obj.tag) ' ' ...
                           num2str(obj.ele.tag) ' ' ...
                           num2str(obj.rho, obj.format) ' ' ...
                           num2str(obj.fc, obj.format) ' ' ...
                           num2str(obj.b, obj.format) ' ' ...
                           num2str(obj.h, obj.format) ' ' ...
                           num2str(obj.d, obj.format) ' ' ...
                           num2str(obj.Fsw, obj.format) ' ' ...
                           num2str(obj.Kdeg, obj.format) ' ' ...
                           num2str(obj.Fres, obj.format) ' ' ...
                           num2str(obj.defType) ' ' ...
                           num2str(obj.forType)];
                       
            if ~isempty(obj.ndI) && ... 
               ~isempty(obj.ndJ) && ...
               ~isempty(obj.dof) && ...
               ~isempty(obj.perpDirn) && ...
               ~isempty(obj.delta)
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.ndI.tag) ' ' ...
                               num2str(obj.ndJ.tag) ' ' ...
                               num2str(obj.dof) ' ' ...
                               num2str(obj.perpDirn) ' ' ...
                               num2str(obj.delta, obj.format)];

            end
            
        end
        
    end
    
end
        