classdef bucklingBrace < handle
    
    properties
        
        % required
        db                      % database instance
        sec                     % section object
        rigidSec                % rigid section object
        geomTransf              % geometric transformation object for brace elements
        geomTransfR             % geometric transformation object for rigid elements
        iNode                   % brace start node
        jNode                   % brace end node
        lri                     % proportion of work point-to-work point length of rigid end zone (work point i to brace end)
        lrj                     % proportion of work point-to-work point length of rigid end zone (work point j to brace end)

        % optional
        nel = 10;               % total number of brace elements (nel >= 2)
        np = 5;                 % number of integration points in brace elements
        impType = 'sine';       % imperfection type:
                                % | sine    sinusoidal imperfection (default)
                                % | iFix    cubic imperfection with i-node fixed and j-node pinned
        impAmp = 500;           % amplitude and direction of initial imperfection (L/impAmp) 
        bucklingMode = 'OOP';   % buckling mode:
                                % | OOP     out-of-plane buckling
                                % | IP      in-plane buckling
        iSpringMat              % material object array for zero-length spring at brace end i (if undefined, pinned end)
        jSpringMat              % material object array for zero-length spring at brace end j (if undefined, pinned end)
        vertVec = [0 1 0];      % vector defining vertical axis in global coordinates
        massDens = 0;           % element mass density (per unit length), from which a lumped-mass matrix is formed (default = 0)
        offset = 0;             % vertical offset of brace
        
        % output
        brNode = OpenSees;      % array of nodes along the brace
        brEle = OpenSees;       % array of elements in the brace
        midEle = [];            % midspan element(s) (length 1 if nel is odd, length 2 if nel is even)
        rigidEle = [];          % rigid offset elements (for recording force)
        iSpring = [];
        jSpring = [];
        
    end
    
    methods
        
        function obj = bucklingBrace(db,sec,rigidSec,geomTransf,geomTransfR,iNode,jNode,lri,lrj,varargin)
                        
            p = inputParser;
            addRequired(p,'db');
            addRequired(p,'sec');
            addRequired(p,'rigidSec');
            addRequired(p,'geomTransf');
            addRequired(p,'geomTransfR');
            addRequired(p,'iNode');
            addRequired(p,'jNode');
            addRequired(p,'lri');
            addRequired(p,'lrj');
            addOptional(p,'nel',obj.nel);
            addOptional(p,'np',obj.np);
            addOptional(p,'impType',obj.impType);
            addOptional(p,'impAmp',obj.impAmp);
            addOptional(p,'bucklingMode',obj.bucklingMode);
            addOptional(p,'iSpringMat',obj.iSpringMat);
            addOptional(p,'jSpringMat',obj.jSpringMat);
            addOptional(p,'vertVec',obj.vertVec);
            addOptional(p,'massDens',obj.massDens);
            addOptional(p,'offset',obj.offset);
            parse(p,db,sec,rigidSec,geomTransf,geomTransfR,iNode,jNode,lri,lrj,varargin{:});
            
            % store variables
            obj.sec = sec;
            obj.rigidSec = rigidSec;
            obj.geomTransf = geomTransf;
            obj.geomTransfR = geomTransfR;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.lri = lri;
            obj.lrj = lrj;
           
            if any(ismember(p.UsingDefaults,'nel')) == 0
                obj.nel = p.Results.nel;
            end
            if any(ismember(p.UsingDefaults,'np')) == 0
                obj.np = p.Results.np;
            end
            if any(ismember(p.UsingDefaults,'impAmp')) == 0
                obj.impAmp = p.Results.impAmp;
            end
            if any(ismember(p.UsingDefaults,'impType')) == 0
                obj.impType = p.Results.impType;
            end   
            if any(ismember(p.UsingDefaults,'bucklingMode')) == 0
                obj.bucklingMode = p.Results.bucklingMode;
            end
            if any(ismember(p.UsingDefaults,'massDens')) == 0
                obj.massDens = p.Results.massDens;
            end
            if any(ismember(p.UsingDefaults,'offset')) == 0
                obj.offset = p.Results.offset;
            end
            
            nn = obj.nel + 1;
            
            % calculate brace length
            dx = obj.jNode.x - obj.iNode.x;
            dy = obj.jNode.y - obj.iNode.y;
            dz = obj.jNode.z - obj.iNode.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % brace work point-to-work point length
                 
            % calculate local nodal coordinates
            offi = obj.lri*L;
            offj = obj.lrj*L;
            Lbr = L - offi - offj; % brace end-to-end length
            nodeLocal.x = linspace(0,Lbr,nn);
            if strcmp(obj.impType,'sine')
                impF = @(x) Lbr/obj.impAmp*sin(x*pi/Lbr); 
            elseif strcmp(obj.impType,'iFix')
                impF = @(x) 27/(4*Lbr*obj.impAmp)*(-1/Lbr*x.^3 + x.^2);
            elseif strcmp(obj.impType, 'cosine')
                impF = @(x) Lbr/obj.impAmp/2*(1 - cos(x*2*pi/Lbr));
            end                
            if strcmp(obj.bucklingMode,'OOP')
                
                nodeLocal.y = zeros(1,nn);
                nodeLocal.z = impF(nodeLocal.x) + obj.offset;
                
            elseif strcmp(obj.bucklingMode,'IP')
                
                nodeLocal.y = impF(nodeLocal.x);
                nodeLocal.z = zeros(1,nn);
                
            end                
            nodeLocal.x = nodeLocal.x + offi;

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
                       0          1 0
                       sin(theta1) 0 cos(theta1)];
                RZ2 = [cos(psi2) -sin(psi2) 0
                       sin(psi2) cos(psi2)  0
                       0         0          1];

                nodeGlobal = (RZ2*RY1*nodeGlobal.').';
                
                % perform translation
                nodeGlobal(:,1) = obj.iNode.x*ones(nn,1) + nodeGlobal(:,1);
                nodeGlobal(:,2) = obj.iNode.y*ones(nn,1) + nodeGlobal(:,2);
                nodeGlobal(:,3) = obj.iNode.z*ones(nn,1) + nodeGlobal(:,3);
            
            % create brace nodes
            brNodeTag = obj.iNode.tag - floor(obj.iNode.tag*1e-8)*1e8 + 3e8;
            obj.brNode(nn,1) = OpenSees;
            for ii = 1:nn
                
                while any(db.nodeTagList == brNodeTag)
                    brNodeTag = brNodeTag+1;
                end
                obj.brNode(ii,1) = OpenSees.model.node(brNodeTag,...
                                                       nodeGlobal(ii,1),...
                                                       nodeGlobal(ii,2),...
                                                       nodeGlobal(ii,3));
                obj.brNode(ii,1).notes = 'brace node';
                db.addNode( obj.brNode(ii,1) );

            end
            
            % create brace elements
            obj.brEle(obj.nel,1) = OpenSees;
            for ii = 1:obj.nel
               
%                 obj.brEle(ii,1) = OpenSees.model.element.forceBeamColumn(obj.brNode(ii).tag,obj.brNode(ii),obj.brNode(ii+1),obj.geomTransf,obj.sec,'maxIters',150,'np',obj.np,'tol',10);
                obj.brEle(ii,1) = OpenSees.model.element.dispBeamColumn(obj.brNode(ii).tag,obj.brNode(ii),obj.brNode(ii+1),obj.geomTransf,obj.sec,'np',obj.np,'intType','Legendre','mass',obj.massDens);
                if mod(obj.nel,2) == 0 && (ii == obj.nel/2 || ii == obj.nel/2+1)
                    obj.midEle = vertcat(obj.midEle,obj.brEle(ii,1));
                elseif mod(obj.nel,2) ~= 0 && ii == round(obj.nel/2)
                    obj.midEle = obj.brEle(ii,1);
                end
                
            end
            db.addElement(obj.brEle);
            
            % (define rigid elements and) determine connectivity for zero-length elements
            if obj.lri == 0
                
                zeroConn(1,:)  = [obj.iNode obj.brNode(1)];
                
            elseif obj.lri > 0
                
                brNodeTag = obj.brNode(1).tag+2e8;
                while any(db.nodeTagList == brNodeTag)
                    brNodeTag = brNodeTag+1;
                end
                rigidNode(1,1) = OpenSees.model.node(brNodeTag,obj.brNode(1).x,obj.brNode(1).y,obj.brNode(1).z);
                db.addNode( rigidNode(1) );
                
%                 obj.rigidEle = OpenSees.model.element.forceBeamColumn(rigidNode(1).tag,obj.iNode,rigidNode(1),obj.geomTransf,obj.rigidSec);
                obj.rigidEle = OpenSees.model.element.dispBeamColumn(rigidNode(1).tag,obj.iNode,rigidNode(1),obj.geomTransfR,obj.rigidSec,'mass',obj.massDens);
                db.addElement( obj.rigidEle(1) );
                
                zeroConn(1,:)  = [rigidNode(1) obj.brNode(1)];
                
            end
            
            if obj.lrj == 0
                
                zeroConn(2,:)  = [obj.jNode obj.brNode(end)];
                
            elseif obj.lrj > 0
                
                brNodeTag = obj.brNode(end).tag+2e8;
                while any(db.nodeTagList == brNodeTag)
                    brNodeTag = brNodeTag+1;
                end                
                rigidNode(2,1) = OpenSees.model.node(brNodeTag,obj.brNode(end).x,obj.brNode(end).y,obj.brNode(end).z);
                db.addNode( rigidNode(2) );
                
%                 obj.rigidEle(2,1) = OpenSees.model.element.forceBeamColumn(rigidNode(2).tag,rigidNode(2),obj.jNode,obj.geomTransf,obj.rigidSec);
                obj.rigidEle(2,1) = OpenSees.model.element.dispBeamColumn(rigidNode(2).tag,rigidNode(2),obj.jNode,obj.geomTransfR,obj.rigidSec,'mass',obj.massDens);
                db.addElement( obj.rigidEle(2) );
                
                zeroConn(2,:)  = [rigidNode(2) obj.brNode(end)];
            
            end
                       
            % create zero-length elements between rigid-offset nodes and brace nodes
            if any(ismember(p.UsingDefaults,'iSpringMat')) == 0
                
                % parse input length
                if length(p.Results.iSpringMat) ~= 6
                    error('invalid input for iSpringMat in OSutility.model.bucklingBrace\n\t> need array of 6 materials (dof 1 through dof 6)');
                end
                
                % store variables
                obj.iSpringMat = p.Results.iSpringMat;
                
                % add zero-length element at brace end i
                obj.iSpring = OpenSees.model.element.zeroLength(obj.brNode(1).tag+3e8,zeroConn(1,1),zeroConn(1,2),obj.iSpringMat,1:6,'x',-[dx dy dz],'yp',obj.vertVec);
                db.addElement(obj.iSpring);
                
            else
                
                % add pin between rigid-offset node and brace node at end i
                db.addEqualDOF( OpenSees.model.constraint.equalDOF(zeroConn(1,1),zeroConn(1,2),1:3) );


            end
            if any(ismember(p.UsingDefaults,'jSpringMat')) == 0
                
                % parse input length
                if length(p.Results.jSpringMat) ~= 6
                    error('invalid input for jSpringMat in OSutility.model.bucklingBrace\n\t> need array of 6 materials (dof 1 through dof 6)');
                end
                
                % store variables
                obj.jSpringMat = p.Results.jSpringMat;
                
                % add zero-length element at brace end j
                obj.jSpring = OpenSees.model.element.zeroLength(obj.brNode(end).tag+3e8,zeroConn(2,1),zeroConn(2,2),obj.jSpringMat,1:6,'x',[dx dy dz],'yp',obj.vertVec);
                db.addElement(obj.jSpring);
                
            else
                
                % add pin between rigid-offset node and brace node at end j
                db.addEqualDOF( OpenSees.model.constraint.equalDOF(zeroConn(2,1),zeroConn(2,2),1:3) );

            end
                        
        end
        
    end
    
end