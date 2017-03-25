classdef bucklingBrace3 < handle
    
    properties
        
        % required
        db = [];                % database instance
        sec = [];               % brace section
        rigidSec = [];          % rigid brace section
        geomTransf = [];        % geometric transformation for brace elements
        geomTransfR = [];       % goemetric transformation for rigid elements
        iNode = [];             % brace work point start node
        jNode = [];             % brace work point end node
        
        % optional
        lri = [];               % length of rigid end zone at end i
        lrj = [];               % length of rigid end zone at end j
        lgpi = [];              % length of gusset plate at end i
        lgpj = [];              % length of gusset plate at end j
        iGPSec = [];            % gusset plate section at end i
        jGPSec = [];            % gusset plate section at end j
        geomTransfP = [];       % geometric transformation for gusset-plate elements
        iSpringMat = [];        % 6-dof spring material at brace end i
        jSpringMat = [];        % 6-dof spring material at brace end j
        nel = 10;               % total number of brace elements (nel >= 2)
        np = 5;                 % number of integration points in brace elements
        impType = 'sine';       % imperfection type:
                                % | sine    sinusoidal imperfection (default)
                                % | iFix    cubic imperfection with i-node fixed and j-node pinned
        impAmp = 500;           % amplitude and direction of initial imperfection (L/impAmp) 
        bucklingMode = 'OOP';   % buckling mode:
                                % | OOP     out-of-plane buckling
                                % | IP      in-plane buckling
        vertVec = [0 1 0];
        massDens = 0;
        
        % output
        iSpringEle = [];        % 6-dof spring element at brace end i
        jSpringEle = [];        % 6-dof spring element at brace end j
        iGPEle = [];            % gusset-plate element at end i
        jGPEle = [];            % gusset-plate element at end j
        
    end
    
    properties (Access = private)
        
        lri_loc = [];           % local x-coordinate of rigid offset node at end i
        lrj_loc = [];           % local x-coordinate of rigid offset node at end j
        lgpi_loc = [];          % local x-coordinate of gusset-plate node at end i
        lgpj_loc = [];          % local x-coordinate of gusset-plate node at end j
        brace_loc = [];         % local x-coordinates of brace nodes
        
    end
   
    methods
   
        function obj = bucklingBrace2(db, sec, rigidSec, geomTransf, geomTransfR, iNode, jNode, varargin)
            
            p = inputParser;
            addRequired(p, 'db');
            addRequired(p, 'sec');
            addRequired(p, 'rigidSec');
            addRequired(p, 'geomTransf');
            addRequired(p, 'geomTransfR');
            addRequired(p, 'iNode');
            addRequired(p, 'jNode');
            addOptional(p, 'lri', obj.lri);
            addOptional(p, 'lrj', obj.lrj);
            addOptional(p, 'lgpi', obj.lgpi);
            addOptional(p, 'lgpj', obj.lgpj);
            addOptional(p, 'iGPSec', obj.iGPSec);
            addOptional(p, 'jGPSec', obj.jGPSec);
            addOptional(p, 'geomTransfP', obj.geomTransfP);
            addOptional(p, 'iSpringMat', obj.iSpringMat);
            addOptional(p, 'jSpringMat', obj.jSpringMat);
            addOptional(p, 'nel', obj.nel);
            addOptional(p, 'np', obj.np);
            addOptional(p, 'impType', obj.impType);
            addOptional(p, 'impAmp', obj.impAmp);
            addOptional(p, 'bucklingMode', obj.bucklingMode);
            addOptional(p, 'vertVec', obj.vertVec);
            addOptional(p, 'massDens', obj.massDens);
            parse(p, db, sec, rigidSec, geomTransf, geomTransfR, iNode, jNode, varargin{:});
            
            % store variables
            obj.db = db;
            obj.sec = sec;
            obj.rigidSec = rigidSec;
            obj.geomTransf = geomTransf;
            obj.geomTransfR = geomTransfR;
            obj.iNode = iNode;
            obj.jNode = jNode;
            
            % calculate brace length
            dx = obj.jNode.x - obj.iNode.x;
            dy = obj.jNode.y - obj.iNode.y;
            dz = obj.jNode.z - obj.iNode.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % brace work point-to-work point length

            % set offset-related properties
            if any(ismember(p.UsingDefaults,'lri')) == 0 && p.Results.lri > 0
                obj.lri = p.Results.lri;
                obj.lri_loc = obj.lri;
            end
            if any(ismember(p.UsingDefaults,'lrj')) == 0 && p.Results.lrj > 0
                obj.lrj = p.Results.lrj;
                obj.lrj_loc = L - obj.lrj;
            end
            if any(ismember(p.UsingDefaults,'lgpi')) == 0 && p.Results.lgpi > 0
                obj.lgpi = p.Results.lgpi;
                if isempty(obj.lri_loc)
                    obj.lgpi_loc = obj.lgpi;
                else
                    obj.lgpi_loc = obj.lri_loc + obj.lgpi;
                end
            end
            if any(ismember(p.UsingDefaults,'lgpj')) == 0 && p.Results.lgpj > 0
                obj.lgpj = p.Results.lgpj;
                if isempty(obj.lrj_loc)
                    obj.lgpj_loc = L - obj.lgpj;
                else
                    obj.lgpj_loc = obj.lrj_loc - obj.lgpj;
                end
            end
            
            % store other optional variables
            if any(ismember(p.UsingDefaults,'geomTransfP')) == 0
                obj.geomTransfP = p.Results.geomTransfP;
            end
            if any(ismember(p.UsingDefaults,'nel')) == 0
                obj.nel = p.Results.nel;
            end
            if any(ismember(p.UsingDefaults,'np')) == 0
                obj.np = p.Results.np;
            end
            if any(ismember(p.UsingDefaults,'impType')) == 0
                obj.impType = p.Results.impType;
            end     
            if any(ismember(p.UsingDefaults,'impAmp')) == 0
                obj.impAmp = p.Results.impAmp;
            end     
            if any(ismember(p.UsingDefaults,'bucklingMode')) == 0
                obj.bucklingMode = p.Results.bucklingMode;
            end
            if any(ismember(p.UsingDefaults,'massDens')) == 0
                obj.massDens = p.Results.massDens;
            end
            
            % calculate local nodal coordinates
            total_offset = sum([obj.lri obj.lrj obj.lgpi obj.lgpj]);
            Lbr = L - total_offset; % brace end-to-end length
            if Lbr <= 0
                error('Error in bucklingBrace2 utility: specified offsets are too large!');
            end
            nn = obj.nel + 1;
            obj.brace_loc.x = linspace(0,Lbr,nn);
            if strcmp(obj.impType,'sine')
                impF = @(x) Lbr/obj.impAmp*sin(x*pi/Lbr); 
            elseif strcmp(obj.impType,'iFix')
                impF = @(x) 27/(4*Lbr*obj.impAmp)*(-1/Lbr*x^3 + x^2);
            end                
            if strcmp(obj.bucklingMode,'OOP')
                
                obj.brace_loc.y = zeros(1,nn);
                obj.brace_loc.z = impF(obj.brace_loc.x);
                
            elseif strcmp(obj.bucklingMode,'IP')
                
                obj.brace_loc.y = impF(obj.brace_loc.x);
                obj.brace_loc.z = zeros(1,nn);
                
            end
            obj.brace_loc.x = obj.brace_loc.x + sum([obj.lri obj.lgpi]);
            nodeLocal.x = horzcat(0,   obj.lri_loc,   obj.lgpi_loc, obj.brace_loc.x(2:end-1),   obj.lgpj_loc,   obj.lrj_loc, L);
            nodeLocal.y = horzcat(0, 0*obj.lri_loc, 0*obj.lgpi_loc, obj.brace_loc.y(2:end-1), 0*obj.lgpj_loc, 0*obj.lrj_loc, 0);
            nodeLocal.z = horzcat(0, 0*obj.lri_loc, 0*obj.lgpi_loc, obj.brace_loc.z(2:end-1), 0*obj.lgpj_loc, 0*obj.lrj_loc, 0);
            nn = length(nodeLocal.x);
            
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
            
            % create rigid offset nodes and elements to gussets
            if ~isempty(obj.lri)
                cur_left_pos = cur_left_pos+1;
 
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                gpi = OpenSees.model.node(newNodeTag, nodeGlobal(cur_left_pos,1), nodeGlobal(cur_left_pos,2), nodeGlobal(cur_left_pos,3));
                db.addNode(gpi);
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                db.addElement( OpenSees.model.element.forceBeamColumn(newEleTag, cur_left_node, gpi,obj.geomTransfR, obj.rigidSec) );
                
                cur_left_node = gpi;
            end
                
            if ~isempty(obj.lrj)
                cur_right_pos = cur_right_pos-1;
 
                newNodeTag = db.getNodeTag(cur_right_node.tag);
                gpj = OpenSees.model.node(newNodeTag, nodeGlobal(cur_right_pos,1), nodeGlobal(cur_right_pos,2), nodeGlobal(cur_right_pos,3));
                db.addNode(gpj);
                
                newEleTag = db.getEleTag(cur_right_node.tag);
                db.addElement( OpenSees.model.element.forceBeamColumn(newEleTag, cur_right_node, gpj, obj.geomTransfR, obj.rigidSec) );
                
                cur_right_node = gpj;
            end
            
            % create gusset nodes and elements to brace
            if ~isempty(obj.lgpi)
                if any(ismember(p.UsingDefaults,'iGPSec')) == 0
                    obj.iGPSec = p.Results.iGPSec;
                else
                    error('No gusset-plate section defined at end i!');
                end
                cur_left_pos = cur_left_pos+1;
 
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                bri = OpenSees.model.node(newNodeTag, nodeGlobal(cur_left_pos,1), nodeGlobal(cur_left_pos,2), nodeGlobal(cur_left_pos,3));
                db.addNode(bri);
%                 db.addFix( OpenSees.model.constraint.equalDOF(cur_left_node, bri, 6) );
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                obj.iGPEle = OpenSees.model.element.forceBeamColumn(newEleTag, cur_left_node, bri, obj.geomTransfP, obj.iGPSec);
                db.addElement(obj.iGPEle);
                
                cur_left_node = bri;
            end
                
            if ~isempty(obj.lgpj)
                if any(ismember(p.UsingDefaults,'iGPSec')) == 0
                    obj.jGPSec = p.Results.jGPSec;
                else
                    error('No gusset-plate section defined at end j!');
                end
                cur_right_pos = cur_right_pos-1;
 
                newNodeTag = db.getNodeTag(cur_right_node.tag);
                brj = OpenSees.model.node(newNodeTag, nodeGlobal(cur_right_pos,1), nodeGlobal(cur_right_pos,2), nodeGlobal(cur_right_pos,3));
                db.addNode(brj);
%                 db.addFix( OpenSees.model.constraint.equalDOF(cur_right_node, brj, 6) );
                
                newEleTag = db.getEleTag(cur_right_node.tag);
                obj.jGPEle = OpenSees.model.element.forceBeamColumn(newEleTag, cur_right_node, brj, obj.geomTransfP, obj.jGPSec);
                db.addElement(obj.jGPEle);
                
                cur_right_node = brj;
            end
            
            % create brace-end spring dummy nodes and elements
            if any(ismember(p.UsingDefaults,'iSpringMat')) == 0
                obj.iSpringMat = p.Results.iSpringMat;
                
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                briDum = OpenSees.model.node(newNodeTag, cur_left_node.x, cur_left_node.y, cur_left_node.z);
                db.addNode(iDum);
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                obj.iSpringEle = OpenSees.model.element.zeroLength(newEleTag, cur_left_node, briDum, obj.iSpringMat, 1:6, 'x', [dx dy dz], 'yp', obj.vertVec);
                db.addElement(obj.iSpringEle);
                
                cur_left_node = briDum;
            end
            
            if any(ismember(p.UsingDefaults,'jSpringMat')) == 0
                obj.jSpringMat = p.Results.jSpringMat;
                
                newNodeTag = db.getNodeTag(cur_right_node.tag);
                brjDum = OpenSees.model.node(newNodeTag, cur_right_node.x, cur_right_node.y, cur_right_node.z);
                db.addNode(jDum);
                
                newEleTag = db.getEleTag(cur_right_node.tag);
                obj.jSpringEle = OpenSees.model.element.zeroLength(newEleTag, cur_right_node, brjDum, obj.jSpringMat, 1:6, 'x', -[dx dy dz], 'yp', obj.vertVec);
                db.addElement(obj.jSpringEle);
                
                cur_right_node = brjDum;
            end
            
            for ii = 1:obj.nel-1
                cur_left_pos = cur_left_pos + 1;
                
                newNodeTag = db.getNodeTag(cur_left_node.tag);
                br(ii) = OpenSees.model.node(newNodeTag, nodeGlobal(cur_left_pos,1), nodeGlobal(cur_left_pos,2), nodeGlobal(cur_left_pos,3));
                br(ii).notes = 'brace node';
                db.addNode(br(ii));
                
                newEleTag = db.getEleTag(cur_left_node.tag);
                db.addElement( OpenSees.model.element.dispBeamColumn(newEleTag, cur_left_node, br(ii), obj.geomTransf, obj.sec, 'np', obj.np) );
                
                cur_left_node = br(ii);
            end
            newEleTag = db.getEleTag(cur_left_node.tag);
            db.addElement( OpenSees.model.element.dispBeamColumn(newEleTag, cur_left_node, cur_right_node, obj.geomTransf, obj.sec, 'np', obj.np) );
            
        end
        
    end
    
end
        