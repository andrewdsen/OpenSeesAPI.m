% planar | Creates nodes for beam work points (at midspans).

classdef beamWP < handle
    
    properties
        
        db = [];    % database object
        mid = [];   % beam midspan locations 
        bElev = []; % beam elevation locations
        
    end
    
    methods
        
        function obj = beamWP(db,mid,bElev)
            
            % store variables
            obj.db = db;
            obj.mid = mid;
            obj.bElev = bElev;
            
            nb = length(obj.mid);   % number of beams
            ns = length(obj.bElev); % number of stories

            counter = 0;
            for ii = 1:nb
                for jj = 2:ns
               
                    counter = counter+1;
                    tag = str2double( ['20' num2str(ii,'%02g') num2str(jj-1,'%02g') '001'] );
                    db.addNode( OpenSees.model.node(tag,mid(ii),obj.bElev(jj),0) );
                    
                end
            end
            
        end
        
    end
    
end