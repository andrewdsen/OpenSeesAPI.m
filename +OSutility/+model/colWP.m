% planar | Creates nodes for column work points.

classdef colWP < handle
    
    properties
        
        db = [];    % database object
        cLine = []; % column line locations 
        bElev = []; % beam elevation locations
        
    end
    
    methods
        
        function obj = colWP(db,cLine,bElev)
            
            % store variables
            obj.db = db;
            obj.cLine = cLine;
            obj.bElev = bElev;
            
            nc = length(obj.cLine); % number of column lines
            ns = length(obj.bElev); % number of stories
            counter = 0;
            for ii = 1:nc
                for jj = 1:ns
               
                    counter = counter+1;
                    tag = str2double( ['10' num2str(ii,'%02g') num2str(jj-1,'%02g') '001'] );
                    db.addNode( OpenSees.model.node(tag,obj.cLine(ii),obj.bElev(jj),0) );
                    
                end
            end
            
        end
        
    end
    
end