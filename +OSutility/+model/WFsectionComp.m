classdef WFsectionComp < OpenSees
    
    properties
    
        % required
        tag = [];       % unique identifying integer tag
        mat = [];       % previously created concrete material object
        WFsec = [];     % previously created wide-flange section object
        beff = [];      % slab effective width
        t = [];         % slab thickness
        offset = [];    % slab offset
        
        % output
        fibers = [];    % array of section fibers
        GJ = [];        % torsional stiffness
    
    end
    
    methods
        
        function obj = WFsectionComp(tag,WFsec,mat,beff,t, offset)
            
            % store variable
            obj.tag = tag;
            obj.WFsec = WFsec;
            obj.mat = mat;
            obj.beff = beff;
            obj.t = t;
            obj.offset = offset;

            % add concrete fibers
            obj.fibers = [ obj.WFsec.fibers
                           OpenSees.model.section.Fiber.patch.rect(obj.mat,WFsec.nfbf,WFsec.nftf,[-obj.beff/2 WFsec.d+obj.offset],[obj.beff/2 WFsec.d+obj.t]) ];
                     
            % do normal WF section 'stuff'
            if any(WFsec.GJ)
                
                J = obj.beff*obj.t^3*(1/3 - 0.21*obj.t/obj.beff*(1 - obj.t^4/(12*obj.beff^4)));
                obj.GJ = WFsec.GJ + obj.mat.G*J;
                WF = OpenSees.model.section.Fiber(obj.tag,obj.fibers,obj.GJ);
                
            else
                
                WF = OpenSees.model.section.Fiber(obj.tag,obj.fibers);
                
            end
            
            obj.cmdLine = WF.cmdLine;
        
        end
    
    end
    
end
    
    