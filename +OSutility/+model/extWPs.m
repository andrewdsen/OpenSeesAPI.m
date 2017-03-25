% (Planar frames only) Creates nodes for external work points.

classdef extWPs < handle
    
    properties
        
        db = [];    % database object
        cLine = []; % column line locations 
        bElev = []; % beam elevation locations
        
    end
    
    methods
        
        function obj = extWPs(db,cLine,bElev)
            
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
                    tag = ['1' num2str(jj-1,'%02g') num2str(ii,'%02g') '0000'];
                    db.addNode( OpenSees.model.node(tag,obj.cLine(ii),obj.bElev(jj),0) );
                    
                end
            end
            
        end
        
    end
    
end