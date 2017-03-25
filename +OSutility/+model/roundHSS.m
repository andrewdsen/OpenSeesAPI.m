% Creates HSS section

classdef roundHSS < OpenSees
    
    properties
        
        % required
        tag = [];   % section tag
        mat = [];   % material object
        D = [];     % diameter of HSS
        t = [];     % thickness of HSS
        
        % optional
        nfc = 4;    % number of fibers along circumference
        nft = 4;    % number of fibers through thickness
        E = [];     % elastic modulus of section
        G = [];     % shear modulus of section
        
        % output
        A = [];     % cross-sectional area
        Iy = [];    % cross-sectional moment of inertia about y-y axis
        Iz = [];    % cross-sectional moment of inertia about z-z axis
        J = [];     % cross-sectional torsional constant
        
    end
    
    methods
        
        function obj = roundHSS(tag, mat, D, t, varargin)

            p = inputParser;
            addRequired(p, 'tag');
            addRequired(p, 'mat');
            addRequired(p, 'D');
            addRequired(p, 't');
            addOptional(p, 'nfc', obj.nfc);
            addOptional(p, 'nft', obj.nft);
            addOptional(p, 'E', obj.E);
            addOptional(p, 'G', obj.G);
            parse(p, tag, mat, D, t, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.D = D;
            obj.t = t;
            
            if any(ismember(p.UsingDefaults, 'nfc')) == 0
                obj.nfc = p.Results.nfc;
            end
            if any(ismember(p.UsingDefaults, 'nft')) == 0
                obj.nft = p.Results.nft;
            end
            if any(ismember(p.UsingDefaults, 'E')) == 0
                obj.E = p.Results.E;
            end
            
            % geometry
            r_ext = D/2;
            r_int = D/2 - t;
            
            % build walls
            fibers = OpenSees.model.section.Fiber.patch.circ(obj.mat, obj.nfc, obj.nft, 0, 0, r_int, r_ext, 0, 360);

            % define cross-sectional properties
            obj.A = pi*(r_ext^2 - r_int^2);
            obj.Iy = pi/2*(r_ext^4 - r_int^4);
            obj.Iz = obj.Iy;
            obj.J = 2/3*pi*(r_ext + r_int)/2*t^3;
            
            % aggregate section
            if any(ismember(p.UsingDefaults, 'G')) == 0
                
                obj.G = p.Results.G;
                HSS = OpenSees.model.section.Fiber(obj.tag,fibers, obj.G*obj.J);
                
            else
                
                HSS = OpenSees.model.section.Fiber(obj.tag, fibers);
                
            end
            
            obj.cmdLine = HSS.cmdLine;
                   
        end
        
    end
    
end