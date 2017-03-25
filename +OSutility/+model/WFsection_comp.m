% Creates WF section

classdef WFsection_comp < OpenSees
    
    properties
        
        % required
        tag = [];   % section tag
        mat_steel = [];     % steel material
        mat_conc  = [];     % concrete material
        d = [];     % section depth
        tw = [];    % web thickness
        bf = [];    % flange width
        tf = [];    % flange thickness
        bs = [];    % effective width of slab
        ts = [];    % slab thickness
        offset = [];    % slab offset
        Es = [];
        Ec = [];
        
        % optional
        nfbf = 4;   % number of fibers along flange width
        nftf = 2;   % number of fibers through flange thickness
        nfT = 4;    % number of fibers along web depth
        nftw = 2;   % number of fibers through web thickness
        GJ = [];    % torsional stiffness of section

        % output
        fibers = [];    % array of section fibers
        xbar = [];
        
    end
    
    methods
        
        function obj = WFsection_comp(tag, mat_steel, mat_conc, d, tw, bf, tf, bs, ts, offset, Es, Ec, varargin)
            
            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'mat_steel');
            addRequired(p,'mat_conc');
            addRequired(p,'d');
            addRequired(p,'tw');
            addRequired(p,'bf');
            addRequired(p,'tf');
            addRequired(p,'bs');
            addRequired(p,'ts');
            addRequired(p,'offset');
            addRequired(p,'Es');
            addRequired(p,'Ec');
            addOptional(p,'nfbf',obj.nfbf);
            addOptional(p,'nftf',obj.nftf);
            addOptional(p,'nfT',obj.nfT);
            addOptional(p,'nftw',obj.nftw);
            addOptional(p,'GJ',obj.GJ);
            parse(p,tag,mat_steel,mat_conc,d,tw,bf,tf,bs,ts,offset,Es,Ec,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.mat_steel = mat_steel;
            obj.mat_conc = mat_conc;
            obj.d = d;
            obj.tw = tw;
            obj.bf = bf;
            obj.tf = tf;
            obj.bs = bs;
            obj.ts = ts;
            obj.offset = offset;
            obj.Es = Es;
            obj.Ec = Ec;
            
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
            
            % geometry
            D = obj.d/2;
            Bf = obj.bf/2;
            T = (obj.d - 2*obj.tf)/2;
            Tw = obj.tw/2;
            Bs = obj.bs/2;
            
            % build section
            obj.fibers = [ OpenSees.model.section.Fiber.patch.rect(obj.mat_steel,obj.nfbf,obj.nftf,[-Bf T], [Bf D])       % top flange
                           OpenSees.model.section.Fiber.patch.rect(obj.mat_steel,obj.nfbf,obj.nftf,[-Bf -D],[Bf -T])      % bottom flange
                           OpenSees.model.section.Fiber.patch.rect(obj.mat_steel,obj.nftw,obj.nfT, [-Tw -T],[Tw T])       % web
                           OpenSees.model.section.Fiber.patch.rect(obj.mat_conc,obj.nfbf,obj.nftf*4,[-Bs T+obj.offset], [Bs T+obj.ts]) ]; % slab

            % aggregate section
            if any(ismember(p.UsingDefaults,'GJ')) == 0
                
                obj.GJ = p.Results.GJ*1.0e8;
                WF = OpenSees.model.section.Fiber(obj.tag,obj.fibers,obj.GJ);
                
            else
                
                WF = OpenSees.model.section.Fiber(obj.tag,obj.fibers);
                
            end
            
            obj.cmdLine = WF.cmdLine;
            
            As = obj.bf*obj.tf*2 + T*2*obj.tw;
            Ac = (obj.ts-obj.offset)*obj.bs;
            obj.xbar = obj.Ec*Ac*((obj.ts-obj.offset)/2+obj.offset+D)/(obj.Ec*Ac + obj.Es*As);
            
        end
        
    end
    
end