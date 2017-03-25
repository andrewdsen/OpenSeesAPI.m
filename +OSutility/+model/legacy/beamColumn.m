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
        lri = [];           % proportion of work point-to-work point length of rigid end zone (work point i to rigid offset end)
        lrj = [];           % proportion of work point-to-work point length of rigid end zone (work point j to rigid offset end)
                
        % optional
        iSpringMat = [];    % material object array for zero-length spring at brace end i (if undefined, fixed end)
        jSpringMat = [];    % material object array for zero-length spring at brace end i (if undefined, fixed end)
        vertVec = [0 1 0];  % vector defining vertical axis in global coordinates
        massDens = 0;       % element mass density (per unit length), from which a lumped-mass matrix is formed (default = 0)
        
        % output
        iDum = [];          % dummy iNode for zero-length element
        jDum = [];          % dummy jNode for zero-length element
        
    end
    
    methods
        
        function obj = beamColumn(db,sec,rigidSec,geomTransf,geomTransfR,iNode,jNode,lri,lrj,varargin)
            
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
            addOptional(p,'massDens',obj.massDens);
            addOptional(p,'iSpringMat',obj.iSpringMat);
            addOptional(p,'jSpringMat',obj.jSpringMat);
            addOptional(p,'vertVec',obj.vertVec);
            parse(p,db,sec,rigidSec,geomTransf,geomTransfR,iNode,jNode,lri,lrj,varargin{:});
            
            % store variables
            obj.db = db;
            obj.sec = sec;
            obj.rigidSec = rigidSec;
            obj.geomTransf = geomTransf;
            obj.geomTransfR = geomTransfR;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.lri = lri;
            obj.lrj = lrj;
            
            if any(ismember(p.UsingDefaults,'massDens')) == 0
                obj.massDens = p.Results.massDens;
            end
            
            % calculate beam-column length
            dx = obj.jNode.x - obj.iNode.x;
            dy = obj.jNode.y - obj.iNode.y;
            dz = obj.jNode.z - obj.iNode.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % beam-column work point-to-work point length
            
            % calculate local nodal coordinates
            offi = obj.lri*L;
            offj = obj.lrj*L;
            Lbc = L - offi - offj; % beam-column length less rigid offsets
            
            nodeLocal.x = [offi offi+Lbc];
            nodeLocal.y = [0 0];
            nodeLocal.z = [0 0];
            
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
                nodeGlobal(:,1) = obj.iNode.x*ones(2,1) + nodeGlobal(:,1);
                nodeGlobal(:,2) = obj.iNode.y*ones(2,1) + nodeGlobal(:,2);
                nodeGlobal(:,3) = obj.iNode.z*ones(2,1) + nodeGlobal(:,3);
                
            % create rigid offset nodes
            newTag = iNode.tag - floor(iNode.tag*1e-8)*1e8 + 5e8;
            if obj.lri > 0
                
                while any(db.nodeTagList == newTag)
                    newTag = newTag+1;
                end
                rigidNode(1,1) = OpenSees.model.node(newTag,nodeGlobal(1,1),nodeGlobal(1,2),nodeGlobal(1,3));
                db.addNode(rigidNode(1,1));
                db.addFix( OpenSees.model.constraint.fix(rigidNode(1),[0 0 1 0 0 0]) );
  
            end
            if any(ismember(p.UsingDefaults,'iSpringMat')) == 0
                
                while any(db.nodeTagList == newTag)
                    newTag = newTag+1;
                end
                obj.iDum = OpenSees.model.node(newTag,obj.iNode.x,obj.iNode.y,obj.iNode.z);
                db.addNode(obj.iDum);
                
            end
                
            if obj.lrj > 0
                
                while any(db.nodeTagList == newTag)
                    newTag = newTag+1;
                end
                rigidNode(2,1) = OpenSees.model.node(newTag,nodeGlobal(2,1),nodeGlobal(2,2),nodeGlobal(2,3));
                db.addNode(rigidNode(2,1));
                db.addFix( OpenSees.model.constraint.fix(rigidNode(2),[0 0 1 0 0 0]) );
 
            end
            if any(ismember(p.UsingDefaults,'jSpringMat')) == 0
                
                while any(db.nodeTagList == newTag)
                    newTag = newTag+1;
                end
                obj.jDum = OpenSees.model.node(newTag,obj.jNode.x,obj.jNode.y,obj.jNode.z);
                db.addNode(obj.jDum);
                
            end
                        
            % create beam-column elements
            newTag = iNode.tag;
            while any(db.eleTagList == newTag)
                newTag = newTag+1;
            end
            
            if any(ismember(p.UsingDefaults,'iSpringMat')) == 0

                % store variables
                obj.iSpringMat = p.Results.iSpringMat;
                
                % add element at beam-column end i
                db.addElement( OpenSees.model.element.zeroLength(obj.iDum.tag,obj.iNode,obj.iDum,obj.iSpringMat,1:6,'x',[dx dy dz],'yp',obj.vertVec) );
                if obj.lri > 0
                    leftRigidNode = obj.iDum;
                    leftNode = rigidNode(1);
                else
                    leftNode = obj.iDum;
                end
                
            else

                if obj.lri > 0
                    leftRigidNode = obj.iNode;
                    leftNode = rigidNode(1);
                else
                    leftNode = obj.iNode;
                end
                
            end
            
            if any(ismember(p.UsingDefaults,'jSpringMat')) == 0

                % store variables
                obj.jSpringMat = p.Results.jSpringMat;
                
                % add element at beam-column end j
                db.addElement( OpenSees.model.element.zeroLength(obj.jDum.tag,obj.jNode,obj.jDum,obj.jSpringMat,1:6,'x',-[dx dy dz],'yp',obj.vertVec) );
                if obj.lrj > 0
                    rightRigidNode = obj.jDum;
                    rightNode = rigidNode(2);
                else
                    rightNode = obj.jDum;
                end
                
            else

                if obj.lrj > 0
                    rightRigidNode = obj.jNode;
                    rightNode = rigidNode(2);
                else
                    rightNode = obj.jNode;
                end
                
            end
            
            db.addElement( OpenSees.model.element.forceBeamColumn(newTag,leftNode,rightNode,obj.geomTransf,obj.sec,'maxIters',500,'np',5,'mass',obj.massDens) );
            
            % create rigid end elements
            if obj.lri > 0
                db.addElement( OpenSees.model.element.forceBeamColumn(rigidNode(1).tag,leftRigidNode,rigidNode(1),obj.geomTransfR,obj.rigidSec,'mass',obj.massDens) );
%                 db.addElement( OpenSees.model.element.dispBeamColumn(rigidNode(1).tag,leftRigidNode,rigidNode(1),obj.geomTransfR,obj.rigidSec,'mass',obj.massDens) );
            end
            
            if obj.lrj > 0
                db.addElement( OpenSees.model.element.forceBeamColumn(rigidNode(2).tag,rigidNode(2),rightRigidNode,obj.geomTransfR,obj.rigidSec,'mass',obj.massDens) );
%                 db.addElement( OpenSees.model.element.dispBeamColumn(rigidNode(2).tag,rigidNode(2),rightRigidNode,obj.geomTransfR,obj.rigidSec,'mass',obj.massDens) );
            end
            
        end
        
    end
    
end