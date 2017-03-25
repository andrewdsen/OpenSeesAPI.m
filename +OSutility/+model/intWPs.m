% (Planar frames only) Creates nodes for internal work points (at beam midspans).

classdef intWPs < handle
    
    properties
        
        db = [];    % database object
        cLine = []; % column line locations 
        bElev = []; % beam elevation locations
        
    end
    
    methods
        
        function obj = intWPs(db,cLine,bElev)
            
            % store variables
            obj.db = db;
            obj.cLine = cLine;
            obj.bElev = bElev;
            
            nc = length(obj.cLine)-1;   % number of beams
            ns = length(obj.bElev)-1;   % number of stories
            counter = 0;
            for ii = 1:nc
                for jj = 1:ns
               
                    counter = counter+1;
                    tag = ['2' num2str(jj,'%02g') num2str(ii,'%02g') '0000'];
                    x = 0.5*(obj.cLine(ii) + obj.cLine(ii+1));
                    y = obj.bElev(jj+1);
                    db.addNode( OpenSees.model.node(tag,x,y,0) );
                    
                end
            end
            
        end
        
    end
    
end