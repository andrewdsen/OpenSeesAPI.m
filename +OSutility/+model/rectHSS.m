% Creates HSS section

classdef rectHSS < OpenSees
    
    properties
        
        % required
        tag = [];   % section tag
        mat = [];   % material object
        by = [];    % width of HSS in local y direction
        bz = [];    % width of HSS in local z direction
        t = [];     % thickness of HSS
        
        % optional
        nfby = 4;   % number of fibers along local y axis (excluding corners)
        nfbz = 4;   % number of fibers along local z axis (excluding corners)
        nft = 4;    % number of fibers through thickness
        E = [];     % elastic modulus of section
        G = [];     % shear modulus of section
        coreMat = []; % material for ghost HSS core (used to aid convergence) 
        
        % output
        numFibers = []; % total number of fibers
        yVerts = [];    % y-coordinates of fiber boundary
        zVerts = [];    % z-coordinates of fiber boundary
        center = [];    % center coordinates of fibers
        corners = [];   % coordinates of corner fibers
        A = [];     % cross-sectional area
        Iy = [];    % cross-sectional moment of inertia about y-y axis
        Iz = [];    % cross-sectional moment of inertia about z-z axis
        J = [];     % cross-sectional torsional constant
        
    end
    
    methods
        
        function obj = rectHSS(tag,mat,by,bz,t,varargin)

            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'mat');
            addRequired(p,'by');
            addRequired(p,'bz');
            addRequired(p,'t');
            addOptional(p,'nfby',obj.nfby);
            addOptional(p,'nfbz',obj.nfbz);
            addOptional(p,'nft',obj.nft);
            addOptional(p,'E',obj.E);
            addOptional(p,'G',obj.G);
            addOptional(p,'coreMat',obj.coreMat);
            parse(p,tag,mat,by,bz,t,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.by = by;
            obj.bz = bz;
            obj.t = t;
            
            if any(ismember(p.UsingDefaults,'nfby')) == 0
                obj.nfby = p.Results.nfby;
            end
            if any(ismember(p.UsingDefaults,'nfbz')) == 0
                obj.nfbz = p.Results.nfbz;
            end
            if any(ismember(p.UsingDefaults,'nft')) == 0
                obj.nft = p.Results.nft;
            end
            if any(ismember(p.UsingDefaults, 'E')) == 0
                obj.E = p.Results.E;
            end

            % geometry
            dy = (obj.by - 2*obj.t)/2;
            dz = (obj.bz - 2*obj.t)/2;
            By = obj.by/2;
            Bz = obj.bz/2;
            obj.numFibers = 2*obj.nft*(obj.nfby + obj.nfbz) + 4*obj.nft*obj.nft;
            
            % build walls
            fibers = [ OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nfby,obj.nft,[-dy dz], [dy  Bz])     % top
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nfby,obj.nft,[-dy -Bz],[dy  -dz])    % bottom
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nft,obj.nfbz,[-By -dz],[-dy dz])     % left
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nft,obj.nfbz,[dy  -dz],[By  dz]) ];  % right
            obj.getGeom(obj.nfby,obj.nft,[-dy dz], [dy  Bz]);
            obj.getGeom(obj.nfby,obj.nft,[-dy -Bz],[dy  -dz]);
            obj.getGeom(obj.nft,obj.nfbz,[-By -dz],[-dy dz]);
            obj.getGeom(obj.nft,obj.nfbz,[dy  -dz],[By  dz]);
                   
            % build corners
            fibers = [ fibers
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nft,obj.nft,[-By -Bz],[-dy -dz])     % bottom left
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nft,obj.nft,[-By dz], [-dy Bz])      % top left
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nft,obj.nft,[dy  dz], [By  Bz])      % top right
                       OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nft,obj.nft,[dy  -Bz],[By  -dz]) ];  % bottom right
            obj.getGeom(obj.nft,obj.nft,[-By -Bz],[-dy -dz]);
            obj.getGeom(obj.nft,obj.nft,[-By dz], [-dy Bz]);
            obj.getGeom(obj.nft,obj.nft,[dy  dz], [By  Bz]);
            obj.getGeom(obj.nft,obj.nft,[dy  -Bz],[By  -dz]);
            obj.corners = [-By -Bz
                            By -Bz
                           -By  Bz
                            By  Bz];
            
            % define cross-sectional properties
            obj.A = obj.by*obj.bz - (obj.by-2*obj.t)*(obj.bz-2*obj.t);
            obj.Iy = (obj.by*obj.bz^3 - (obj.by-2*obj.t)*(obj.bz-2*obj.t)^3)/12;
            obj.Iz = (obj.bz*obj.by^3 - (obj.bz-2*obj.t)*(obj.by-2*obj.t)^3)/12;
            
            Rc = 1.5*obj.t;
            Ap = (obj.by-obj.t)*(obj.bz-obj.t) - Rc^2*(4-pi);
            p2 = 2*((obj.by-obj.t) + (obj.bz-obj.t)) - 2*Rc*(4-pi);
            obj.J = 4*Ap^2*obj.t/p2;
                   
            % aggregate section
            if any(ismember(p.UsingDefaults,'G')) == 0
                
                obj.G = p.Results.G;
                HSS = OpenSees.model.section.Fiber(obj.tag, fibers, obj.G*obj.J);
                
            else
                
                HSS = OpenSees.model.section.Fiber(obj.tag,fibers);
                
            end
            
            obj.cmdLine = HSS.cmdLine;
                   
        end
        
        function getGeom(obj,nfy,nfz,iCoords,jCoords)
           
            ySpan = abs(jCoords(1) - iCoords(1));
            zSpan = abs(jCoords(2) - iCoords(2));
            yWidth = ySpan/nfy;
            zWidth = zSpan/nfz;
            
            YVerts = zeros(nfy*nfz,4);
            ZVerts = zeros(nfy*nfz,4);
            Center = zeros(nfy*nfz,2);
            ind = 1;
            yCur = iCoords(1) + yWidth/2;
            for ii = 1:nfy
                zCur = iCoords(2) + zWidth/2;
                for jj = 1:nfz
                    Center(ind,:) = [yCur zCur];
                    YVerts(ind,:) = [yCur-yWidth/2 yCur+yWidth/2 yCur+yWidth/2 yCur-yWidth/2];
                    ZVerts(ind,:) = [zCur-zWidth/2 zCur-zWidth/2 zCur+zWidth/2 zCur+zWidth/2];
                    zCur = zCur + zWidth;
                    ind = ind + 1;
                end
                yCur = yCur + yWidth;
            end
            
            obj.yVerts = vertcat(obj.yVerts,YVerts);
            obj.zVerts = vertcat(obj.zVerts,ZVerts);
            obj.center = vertcat(obj.center,Center);
            
        end
        
    end
    
end