% Creates WF section

classdef PDsection < OpenSees
    
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
        GJ = [];    % torsional stiffness of section

        % output
        fibers = [];    % array of section fibers
        
    end
    
    methods
        
        function obj = PDsection(tag, mat, d, tw, bf, tf, varargin)
            
            p = inputParser;
            addRequired(p, 'tag');
            addRequired(p, 'mat');
            addRequired(p, 'd');
            addRequired(p, 'tw');
            addRequired(p, 'bf');
            addRequired(p, 'tf');
            addOptional(p, 'nfbf', obj.nfbf);
            addOptional(p, 'nftf', obj.nftf);
            addOptional(p, 'nfT', obj.nfT);
            addOptional(p, 'nftw', obj.nftw);
            addOptional(p, 'GJ', obj.GJ);
            parse(p, tag, mat, d, tw, bf, tf, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.mat = mat;
            obj.d = d;
            obj.tw = tw;
            obj.bf = bf;
            obj.tf = tf;
            
            if any(ismember(p.UsingDefaults, 'nfbf')) == 0
                obj.nfbf = p.Results.nfbf;
            end
            if any(ismember(p.UsingDefaults, 'nftf')) == 0
                obj.nftf = p.Results.nftf;
            end
            if any(ismember(p.UsingDefaults, 'nfT')) == 0
                obj.nfT = p.Results.nfT;
            end
            if any(ismember(p.UsingDefaults, 'nftw')) == 0
                obj.nftw = p.Results.nftw;
            end
            
            % geometry
            D = obj.d/2;
            Bf = obj.bf/2;
            T = (obj.d - 2*obj.tf)/2;
            Tw = obj.tw/2;
            
            % build section
            obj.fibers = [ OpenSees.model.section.Fiber.patch.rect(obj.mat, obj.nfbf, obj.nftf, [-Bf T],  [Bf D])       % top flange
                           OpenSees.model.section.Fiber.patch.rect(obj.mat, obj.nfbf, obj.nftf, [-Bf -D], [Bf -T])      % bottom flange
                           OpenSees.model.section.Fiber.patch.rect(obj.mat, obj.nftw, obj.nfT,  [-Tw -T], [Tw T]) ];    % web
                   
            % aggregate section
            if any(ismember(p.UsingDefaults, 'GJ')) == 0
                
                obj.GJ = p.Results.GJ;
                WF = OpenSees.model.section.Fiber(obj.tag, obj.fibers, obj.GJ);
                
            else
                
                WF = OpenSees.model.section.Fiber(obj.tag, obj.fibers);
                
            end
            
            obj.cmdLine = WF.cmdLine;
            
        end
        
    end
    
end