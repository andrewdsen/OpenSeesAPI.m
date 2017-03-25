classdef beamColumn < handle
    
    properties
        
        % required
        db = [];            % database instance
        sec = [];           % section object
        rigidSec = [];      % rigid section object
        geomTransf = [];    % geometric transformation object for beam-column elements
        geomTransfR = [];   % geometric transformation object for rigid elements
        iNode = [];         % beam-column start node
        jNode = [];         % beam-column end node
                
        % optional
        cflri = [];         % length of rigid end zone due to column face at end i (e.g., d/2 of column)
        cflrj = [];         % length of rigid end zone due to column face at end j (e.g., d/2 of column)
        lri = [];           % length of rigid end zone outside column face at end i
        lrj = [];           % length of rigid end zone outside column face at end j
        iSpringMat = [];    % material object array for zero-length spring at brace end i (if undefined, fixed end)
        jSpringMat = [];    % material object array for zero-length spring at brace end i (if undefined, fixed end)
        iSpringFlag = [];
        jSpringFlag = [];
        vertVec = [0 1 0];  % vector defining vertical axis in global coordinates
        massDens = 0;       % element mass density (per unit length), from which a lumped-mass matrix is formed (default = 0)
        recLocations = [];  % array of recorder locations measured from iNode (CANNOT BE IN OFFSET REGIONS)
        
        % output
        iSpringEle = [];
        jSpringEle = [];
        recEle = OpenSees;
        mainEle = [];
        
    end
    
    properties (Access = private)
           
        cflri_loc = [];     % local x-coordinate of column-face offset node at end i
        cflrj_loc = [];     % local x-coordinate of column-face offset node at end j
        lri_loc = [];       % local x-coordinate of offset node outside column face at end i
        lrj_loc = [];       % local x-coordinate of offset node outside column face at end j
            
    end
    
    methods
        
        function obj = beamColumn(db,sec,rigidSec,geomTransf,geomTransfR,iNode,jNode,varargin)
            
            p = inputParser;
            addRequired(p,'db');
            addRequired(p,'sec');
            addRequired(p,'rigidSec');
            addRequired(p,'geomTransf');
            addRequired(p,'geomTransfR');
            addRequired(p,'iNode');
            addRequired(p,'jNode');
            addOptional(p,'cflri',obj.cflri);
            addOptional(p,'cflrj',obj.cflrj);
            addOptional(p,'lri',obj.lri);
            addOptional(p,'lrj',obj.lrj);
            addOptional(p,'iSpringMat',obj.iSpringMat);
            addOptional(p,'jSpringMat',obj.jSpringMat);
            addOptional(p,'iSpringFlag',obj.iSpringFlag);
            addOptional(p,'jSpringFlag',obj.jSpringFlag);
            addOptional(p,'vertVec',obj.vertVec);
            addOptional(p,'massDens',obj.massDens);
            addOptional(p,'recLocations',obj.recLocations);
            parse(p,db,sec,rigidSec,geomTransf,geomTransfR,iNode,jNode,varargin{:});
            
            % store variables
            obj.db = db;
            obj.sec = sec;
            obj.rigidSec = rigidSec;
            obj.geomTransf = geomTransf;
            obj.geomTransfR = geomTransfR;
            obj.iNode = iNode;
            obj.jNode = jNode;
            
            if any(ismember(p.UsingDefaults, 'vertVec')) == 0
                obj.vertVec = p.Results.vertVec;
            end
                                    
            % calculate beam-column length
            dx = obj.jNode.x - obj.iNode.x;
            dy = obj.jNode.y - obj.iNode.y;
            dz = obj.jNode.z - obj.iNode.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % beam-column work point-to-work point length
            
            % set offset-related properties
            if any(ismember(p.UsingDefaults,'cflri')) == 0 && p.Results.cflri > 0
                obj.cflri = p.Results.cflri;
                obj.cflri_loc = obj.cflri;
            end
            if any(ismember(p.UsingDefaults,'cflrj')) == 0 && p.Results.cflrj > 0
                obj.cflrj = p.Results.cflrj;
                obj.cflrj_loc = L - obj.cflrj;
            end
            if any(ismember(p.UsingDefaults,'lri')) == 0 && p.Results.lri > 0
                obj.lri = p.Results.lri;
                if isempty(obj.cflri_loc)
                    obj.lri_loc = obj.lri;
                else
                    obj.lri_loc = obj.cflri_loc + obj.lri;
                end
            end
            if any(ismember(p.UsingDefaults,'lrj')) == 0 && p.Results.lrj > 0
                obj.lrj = p.Results.lrj;
                if isempty(obj.cflrj_loc)
                    obj.lrj_loc = L - obj.lrj;
                else
                    obj.lrj_loc = obj.cflrj_loc - obj.lrj;
                end
            end
            
            % store other optional variables                        
            if any(ismember(p.UsingDefaults,'massDens')) == 0
                obj.massDens = p.Results.massDens;
            end
            if any(ismember(p.UsingDefaults,'recLocations')) == 0
                obj.recLocations = sort(p.Results.recLocations);
                if any(obj.recLocations <= sum([obj.cflri obj.lri])) || any(obj.recLocations >= L-sum([obj.cflrj obj.lrj]))
                    error('Error in beamColumn utility: specified recorder locations are outside main element!');
                end
                if iscolumn(obj.recLocations)
                    obj.recLocations = obj.recLocations.';
                end
            end
                        
            % calculate local nodal coordinates
            
            nodeLocal.x = [0 obj.cflri_loc obj.lri_loc obj.recLocations obj.lrj_loc obj.cflrj_loc L];
            if ~issorted(nodeLocal.x)
                error('Error in beamColumn utility: specified offsets are too large!');
            end
            
            nn = length(nodeLocal.x);
            nodeLocal.y = zeros(1,nn);
            nodeLocal.z = zeros(1,nn);
            
            % calculate global nodal coordinates
                
                % initialize global nodal coordinates
                nodeGlobal = [nodeLocal.x.' nodeLocal.y.' nodeLocal.z.'];

                % perform rotation
                theta1 = atan2(dz,dx);
                if dx == 0
                    psi2 = atan2(dy,sqrt(dx^2+dz^2));
                else
                    psi2 = sign(dx)*atan2(dy,sqrt(dx^2+dz^2));
                end
                
                RY1 = [cos(theta1) 0 -sin(theta1)
                       0           1 0
                       sin(theta1) 0 cos(theta1)];
                RZ2 = [cos(psi2) -sin(psi2) 0
                       sin(psi2) cos(psi2)  0
                       0         0          1];

                nodeGlobal = (RZ2*RY1*nodeGlobal.').';
                
                % perform translation
                nodeGlobal(:,1) = obj.iNode.x*ones(nn,1) + nodeGlobal(:,1);
                nodeGlobal(:,2) = obj.iNode.y*ones(nn,1) + nodeGlobal(:,2);
                nodeGlobal(:,3) = obj.iNode.z*ones(nn,1) + nodeGlobal(:,3);
                
            % initialize left and right
            cur_left_node = obj.iNode;
            cur_left_pos = 1;
            cur_right_node = obj.jNode;
            cur_right_pos = nn;
            
            % create column face nodes and elements
            if ~isempty(obj.cflri)
                cur_left_pos = cur_left_pos+1;
 
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                cfi = OpenSees.model.node(newNodeTag,nodeGlobal(cur_left_pos,1),nodeGlobal(cur_left_pos,2),nodeGlobal(cur_left_pos,3));
                db.addNode(cfi);
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                curEle = OpenSees.model.element.forceBeamColumn(newEleTag,cur_left_node,cfi,obj.geomTransfR,obj.rigidSec);
                curEle.flag = 'rigid';
                db.addElement( curEle );
                
                cur_left_node = cfi;
            end
                
            if ~isempty(obj.cflrj)
                cur_right_pos = cur_right_pos-1;
 
                newNodeTag = db.getNodeTag(cur_right_node.tag);
                cfj = OpenSees.model.node(newNodeTag,nodeGlobal(cur_right_pos,1),nodeGlobal(cur_right_pos,2),nodeGlobal(cur_right_pos,3));
                db.addNode(cfj);
                
                newEleTag = db.getEleTag(cur_right_node.tag);
                curEle = OpenSees.model.element.forceBeamColumn(newEleTag,cur_right_node,cfj,obj.geomTransfR,obj.rigidSec);
                curEle.flag = 'rigid';
                db.addElement( curEle );
                
                cur_right_node = cfj;
            end
            
            % create column-face-spring dummy nodes and elements
            if any(ismember(p.UsingDefaults,'iSpringMat')) == 0
                obj.iSpringMat = p.Results.iSpringMat;
                
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                iDum = OpenSees.model.node(newNodeTag,cur_left_node.x,cur_left_node.y,cur_left_node.z);
                db.addNode(iDum);
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                obj.iSpringEle = OpenSees.model.element.zeroLength(newEleTag,cur_left_node,iDum,obj.iSpringMat,1:6,'x',[dx dy dz],'yp',obj.vertVec);
                if any(ismember(p.UsingDefaults, 'iSpringFlag')) == 0
                    obj.iSpringFlag = p.Results.iSpringFlag;
                    obj.iSpringEle.flag = obj.iSpringFlag;
                end
                db.addElement(obj.iSpringEle);
                
                cur_left_node = iDum;
            end
            
            if any(ismember(p.UsingDefaults,'jSpringMat')) == 0
                obj.jSpringMat = p.Results.jSpringMat;
                
                newNodeTag = db.getNodeTag(cur_right_node.tag);
                jDum = OpenSees.model.node(newNodeTag,cur_right_node.x,cur_right_node.y,cur_right_node.z);
                db.addNode(jDum);
                
                newEleTag = db.getEleTag(cur_right_node.tag);
                obj.jSpringEle = OpenSees.model.element.zeroLength(newEleTag,cur_right_node,jDum,obj.jSpringMat,1:6,'x',-[dx dy dz],'yp',obj.vertVec);
                if any(ismember(p.UsingDefaults, 'jSpringFlag')) == 0
                    obj.jSpringFlag = p.Results.jSpringFlag;
                    obj.jSpringEle.flag = obj.jSpringFlag;
                end
                db.addElement(obj.jSpringEle);
                
                cur_right_node = jDum;
            end
            
            % create additional offset nodes and elements
            if ~isempty(obj.lri)
                cur_left_pos = cur_left_pos+1;
 
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                offi = OpenSees.model.node(newNodeTag,nodeGlobal(cur_left_pos,1),nodeGlobal(cur_left_pos,2),nodeGlobal(cur_left_pos,3));
                db.addNode(offi);
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                curEle = OpenSees.model.element.forceBeamColumn(newEleTag,cur_left_node,offi,obj.geomTransfR,obj.rigidSec);
                curEle.flag = 'rigid';
                db.addElement(curEle);
                
                cur_left_node = offi;
            end

            if ~isempty(obj.lrj)
                cur_right_pos = cur_right_pos-1;
 
                newNodeTag = db.getNodeTag(cur_right_node.tag);
                offj = OpenSees.model.node(newNodeTag,nodeGlobal(cur_right_pos,1),nodeGlobal(cur_right_pos,2),nodeGlobal(cur_right_pos,3));
                db.addNode(offj);
                
                newEleTag = db.getEleTag(cur_right_node.tag);
                curEle = OpenSees.model.element.forceBeamColumn(newEleTag,cur_right_node,offj,obj.geomTransfR,obj.rigidSec);
                curEle.flag = 'rigid';
                db.addElement(curEle);
                
                cur_right_node = offj;
            end
            
            % create beam-column element
            if ~isempty(obj.recLocations)
                recNode(length(obj.recLocations),1) = OpenSees;
                obj.recEle(length(obj.recLocations),1) = OpenSees;
                for ii = 1:length(obj.recLocations)
                    cur_left_pos = cur_left_pos+1;
                    
                    newNodeTag = db.getNodeTag(cur_left_node.tag);
                    recNode(ii,1) = OpenSees.model.node(newNodeTag,nodeGlobal(cur_left_pos,1),nodeGlobal(cur_left_pos,2),nodeGlobal(cur_left_pos,3));
                    db.addNode(recNode(ii,1));
                    
                    newEleTag = db.getEleTag(cur_left_node.tag);
                    obj.recEle(ii,1) = OpenSees.model.element.forceBeamColumn(newEleTag,cur_left_node,recNode(ii,1),obj.geomTransf,obj.sec,'maxIters',500,'np',5,'mass',obj.massDens, 'tol', 10);
                    db.addElement(obj.recEle(ii,1));
                    
                    cur_left_node = recNode(ii,1);                    
                end
            end
            
            newEleTag = db.getEleTag(cur_left_node.tag);
            obj.mainEle = OpenSees.model.element.forceBeamColumn(newEleTag,cur_left_node,cur_right_node,obj.geomTransf,obj.sec,'maxIters',500,'np',5,'mass',obj.massDens, 'tol', 10);
            db.addElement(obj.mainEle);

        end
        
    end
    
end