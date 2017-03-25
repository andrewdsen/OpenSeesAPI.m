% Creates HSS section

classdef rectSection < OpenSees
    
    properties
        
        % required
        tag = [];   % section tag
        mat = [];   % material object
        d = [];     % depth of section
        t = [];     % thickness of section
        
        % optional
        nfd = 4;    % number of fibers along local y axis
        nft = 2;    % number of fibers along local z axis
        GJ = [];    % torsional stiffness of section
        
        % output
        numFibers = []; % total number of fibers
        yVerts = [];    % y-coordinates of fiber boundary
        zVerts = [];    % z-coordinates of fiber boundary
        center = [];    % center coordinates of fibers
        
    end
    
    methods
        
        function obj = rectSection(tag,mat,d,t,varargin)

            p = inputParser;
            addRequired(p,'tag');
            addRequired(p,'mat');
            addRequired(p,'d');
            addRequired(p,'t');
            addOptional(p,'nfd',obj.nfd);
            addOptional(p,'nft',obj.nft);
            addOptional(p,'GJ',obj.GJ);
            parse(p,tag,mat,d,t,varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.d = d;
            obj.t = t;
            
            if any(ismember(p.UsingDefaults,'nfd')) == 0
                obj.nfd = p.Results.nfd;
            end
            if any(ismember(p.UsingDefaults,'nft')) == 0
                obj.nft = p.Results.nft;
            end

            % geometry
            obj.numFibers = obj.nfd*obj.nft;
            iCoords = [-obj.d/2 -obj.t/2];
            jCoords = [obj.d/2  obj.t/2];
            
            % build section
            fibers = OpenSees.model.section.Fiber.patch.rect(obj.mat,obj.nfd,obj.nft,iCoords,jCoords);
                               
            % aggregate section
            if any(ismember(p.UsingDefaults,'GJ')) == 0
                
                obj.GJ = p.Results.GJ;
                rectSection = OpenSees.model.section.Fiber(obj.tag,fibers,obj.GJ);
                
            else
                
                rectSection = OpenSees.model.section.Fiber(obj.tag,fibers);
                
            end
            
            obj.cmdLine = rectSection.cmdLine;
                   
        end
        
    end
    
end