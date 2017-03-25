% planar | Creates nodes for beam work points (at midspans).

classdef beamInt < handle
    
    properties
        
        db = [];    % database object
        int = [];   % beam midspan locations 
        bElev = []; % beam elevation locations
        
        node = [];  % array of new nodes
        
    end
    
    methods
        
        function obj = beamInt(db,int,bElev)
            
            % store variables
            obj.db = db;
            obj.int = int;
            obj.bElev = bElev;
            
            nb = size(obj.int,1);   % number of beams
            ni = size(obj.int,2);   % number of interstitial points
            ns = length(obj.bElev); % number of stories

            counter = 0;
            for ii = 1:nb
                for jj = 2:ns
                    for kk = 1:ni
               
                        counter = counter+1;
                        tag = str2double( ['31' num2str(ii,'%02g') num2str(jj-1,'%02g') num2str(kk,'%03g')] );
                        obj.node = [obj.node; OpenSees.model.node(tag,obj.int(ii,kk),obj.bElev(jj),0)];
                    
                    end
                end
            end
            
            db.addNode(obj.node);
            
        end
        
    end
    
end