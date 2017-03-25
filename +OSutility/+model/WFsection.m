% Creates WF section

classdef WFsection < OpenSees
    
    properties
        
        % required
        tag = [];   % section tag
        mat = [];   % material object
        d = [];     % section depth
        tw = [];    % web thickness
        bf = [];    % flange width
        tf = [];    % flange thickness
        
        % optional
        nfbf = 4;   % number of fibers along flange width
        nftf = 2;   % number of fibers through flange thickness
        nfT = 4;    % number of fibers along web depth
        nftw = 2;   % number of fibers through web thickness
        E = [];     % 
        G = [];     % shear modulus of section
        mat_web = [];   % different material for the web
        
        % output
        fibers = [];    % array of section fibers
        A = [];         % cross-sectional area
        Iy = [];        % cross-sectional moment of inertia about y-y axis
        Iz = [];        % cross-sectional moment of inertia about z-z axis
        J = [];         % cross-sectional torsional constant
        
    end
    
    methods
        
        function obj = WFsection(tag,mat,d,tw,bf,tf,varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'mat');
            addRequired(p,'d');
            addRequired(p,'tw');
            addRequired(p,'bf');
            addRequired(p,'tf');
            addOptional(p,'nfbf',obj.nfbf);
            addOptional(p,'nftf',obj.nftf);
            addOptional(p,'nfT',obj.nfT);
            addOptional(p,'nftw',obj.nftw);
            addOptional(p, 'E', obj.E);
            addOptional(p, 'G', obj.G);
            addOptional(p, 'mat_web', obj.mat_web);
            parse(p,tag,mat,d,tw,bf,tf,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.d = d;
            obj.tw = tw;
            obj.bf = bf;
            obj.tf = tf;
            
            if any(ismember(p.UsingDefaults,'nfbf')) == 0
                obj.nfbf = p.Results.nfbf;
            end
            if any(ismember(p.UsingDefaults,'nftf')) == 0
                obj.nftf = p.Results.nftf;
            end
            if any(ismember(p.UsingDefaults,'nfT')) == 0
                obj.nfT = p.Results.nfT;
            end
            if any(ismember(p.UsingDefaults,'nftw')) == 0
                obj.nftw = p.Results.nftw;
            end
            if any(ismember(p.UsingDefaults, 'E')) == 0
                obj.E = p.Results.E;
            end
            if any(ismember(p.UsingDefaults, 'mat_web')) == 0
                obj.mat_web = p.Results.mat_web;
            else
                obj.mat_web = obj.mat;
            end
            
            % geometry
            D = obj.d/2;
            Bf = obj.bf/2;
            T = (obj.d - 2*obj.tf)/2;
            Tw = obj.tw/2;
            obj.A = obj.d*obj.bf - 2*T*(obj.bf - obj.tw);
            obj.Iy = 1/12*obj.tw*(2*T)^3 + 2*(1/12*obj.bf*obj.tf^3 + obj.bf*obj.tf*(T + obj.tf/2)^2);
            obj.Iz = 1/12*2*T*obj.tw^3 + 2*(1/12*obj.tf*obj.bf^3);
            obj.J = 1/3*(2*obj.bf*obj.tf^3 + (obj.d - obj.tf)*obj.tw^3);
            
            % build section
            obj.fibers = [ OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nfbf,obj.nftf,[-Bf T], [Bf D])       % top flange
                           OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nfbf,obj.nftf,[-Bf -D],[Bf -T])      % bottom flange
                           OpenSees.model.section.Fiber.patch.rect(obj.mat_web,obj.nftw,obj.nfT, [-Tw -T],[Tw T]) ];    % web
                   
            % aggregate section
            if any(ismember(p.UsingDefaults,'G')) == 0
                
                obj.G = p.Results.G;
                WF = OpenSees.model.section.Fiber(obj.tag,obj.fibers,obj.G*obj.J);
                
            else
                
                WF = OpenSees.model.section.Fiber(obj.tag,obj.fibers);
                
            end
            
            obj.cmdLine = WF.cmdLine;
            
        end
        
    end
    
end
                   
                   
                   
                   
                   
                   