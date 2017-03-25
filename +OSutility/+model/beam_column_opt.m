classdef beam_column_opt < handle
    
    properties
        
        % required
        db = [];                % database instance
        sec = [];               % section instance
        sec_meta = [];          % section metadata
        geom_transf = [];       % geometric transformation object for beam-column elements
        geom_transf_rig = [];   % geometric transformation object for rigid elements
        node_i = [];            % beam-column start node
        node_j = [];            % beam-column end node
                
        % optional
        Es = 29000;             % elastic modulus
        Gs = 10000;             % shear modulus
        rsf = 1.0e4;            % rigid scale factor
        cflri = [];             % length of rigid end zone due to column face at end i (e.g., d/2 of column)
        cflrj = [];             % length of rigid end zone due to column face at end j (e.g., d/2 of column)
        lri = [];               % length of rigid end zone outside column face at end i
        lrj = [];               % length of rigid end zone outside column face at end j
        spring_mat_i = [];      % material object array for zero-length spring at brace end i (if undefined, fixed end)
        spring_mat_j = [];      % material object array for zero-length spring at brace end i (if undefined, fixed end)
        spring_flag_i = [];     % element flag for spring at brace end i
        spring_flag_j = [];     % element flag for spring at brace end j
        vert_vec = [0 1 0];     % vector defining vertical axis in global coordinates
        mass_dens = 0;          % element mass density (per unit length), from which a lumped-mass matrix is formed (default = 0)
        node_rigid_fix = [];    % fixity of new rigid nodes
        nel = 1;                % number of nonlinear beam-column elements
        
        % output
        spring_ele_i = [];
        spring_ele_j = [];
        line_ele = [];
        bc_ele = [];
        
    end
    
    properties (Access = private)
           
        cflri_loc = [];     % local x-coordinate of column-face offset node at end i
        cflrj_loc = [];     % local x-coordinate of column-face offset node at end j
        lri_loc = [];       % local x-coordinate of offset node outside column face at end i
        lrj_loc = [];       % local x-coordinate of offset node outside column face at end j
            
    end
    
    methods
        
        function obj = beam_column_opt(db, sec, sec_meta, geom_transf, geom_transf_rig, node_i, node_j, varargin)
            
            p = inputParser;
            addRequired(p, 'db');
            addRequired(p, 'sec');
            addRequired(p, 'sec_meta');
            addRequired(p, 'geom_transf');
            addRequired(p, 'geom_transf_rig');
            addRequired(p, 'node_i');
            addRequired(p, 'node_j');
            addOptional(p, 'Es', obj.Es);
            addOptional(p, 'Gs', obj.Gs);
            addOptional(p, 'rsf', obj.rsf);
            addOptional(p, 'cflri', obj.cflri);
            addOptional(p, 'cflrj', obj.cflrj);
            addOptional(p, 'lri', obj.lri);
            addOptional(p, 'lrj', obj.lrj);
            addOptional(p, 'spring_mat_i', obj.spring_mat_i);
            addOptional(p, 'spring_mat_j', obj.spring_mat_j);
            addOptional(p, 'spring_flag_i', obj.spring_flag_i);
            addOptional(p, 'spring_flag_j', obj.spring_flag_j);
            addOptional(p, 'vert_vec', obj.vert_vec);
            addOptional(p, 'mass_dens', obj.mass_dens);
            addOptional(p, 'node_rigid_fix', obj.node_rigid_fix);
            addOptional(p, 'nel', obj.nel);
            parse(p, db, sec, sec_meta, geom_transf, geom_transf_rig, node_i, node_j, varargin{:});
            
            % store variables
            obj.db = db;
            obj.sec = sec;
            obj.sec_meta = sec_meta;
            obj.geom_transf = geom_transf;
            obj.geom_transf_rig = geom_transf_rig;
            obj.node_i = node_i;
            obj.node_j = node_j;
            
            if any(ismember(p.UsingDefaults, 'Es')) == 0
                obj.Es = p.Results.Es;
            end
            if any(ismember(p.UsingDefaults, 'Gs')) == 0
                obj.Gs = p.Results.Gs;
            end
            if any(ismember(p.UsingDefaults, 'rsf')) == 0
                obj.rsf = p.Results.rsf;
            end
            if any(ismember(p.UsingDefaults, 'vert_vec')) == 0
                obj.vert_vec = p.Results.vert_vec;
            end
            if any(ismember(p.UsingDefaults, 'nel')) == 0
                obj.nel = p.Results.nel;
            end
                                    
            % calculate beam-column length
            dx = obj.node_j.x - obj.node_i.x;
            dy = obj.node_j.y - obj.node_i.y;
            dz = obj.node_j.z - obj.node_i.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % beam-column work point-to-work point length
            
            % set offset-related properties
            if any(ismember(p.UsingDefaults, 'cflri')) == 0 && p.Results.cflri > 0
                obj.cflri = p.Results.cflri;
                obj.cflri_loc = obj.cflri;
            end
            if any(ismember(p.UsingDefaults, 'cflrj')) == 0 && p.Results.cflrj > 0
                obj.cflrj = p.Results.cflrj;
                obj.cflrj_loc = L - obj.cflrj;
            end
            if any(ismember(p.UsingDefaults, 'lri')) == 0 && p.Results.lri > 0
                obj.lri = p.Results.lri;
                if isempty(obj.cflri_loc)
                    obj.lri_loc = obj.lri;
                else
                    obj.lri_loc = obj.cflri_loc + obj.lri;
                end
            end
            if any(ismember(p.UsingDefaults, 'lrj')) == 0 && p.Results.lrj > 0
                obj.lrj = p.Results.lrj;
                if isempty(obj.cflrj_loc)
                    obj.lrj_loc = L - obj.lrj;
                else
                    obj.lrj_loc = obj.cflrj_loc - obj.lrj;
                end
            end
            
            % store other optional variables                        
            if any(ismember(p.UsingDefaults, 'mass_dens')) == 0
                obj.mass_dens = p.Results.mass_dens;
            end
            
            if any(ismember(p.UsingDefaults, 'node_rigid_fix')) == 0
                obj.node_rigid_fix = p.Results.node_rigid_fix;
            end
                        
            % calculate local nodal coordinates
            node_local.x = [0 obj.cflri_loc obj.lri_loc obj.lrj_loc obj.cflrj_loc L];
            if ~issorted(node_local.x)
                error('Error in beam_column_opt utility: specified offsets are too large!');
            end
            
            nn = length(node_local.x);
            node_local.y = zeros(1, nn);
            node_local.z = zeros(1, nn);
            
            % calculate global nodal coordinates
                
                % initialize global nodal coordinates
                node_global = [node_local.x.' node_local.y.' node_local.z.'];

                % perform rotation
                theta1 = atan2(dz, dx);
                if dx == 0
                    psi2 = atan2(dy, sqrt(dx^2 + dz^2));
                else
                    psi2 = sign(dx)*atan2(dy, sqrt(dx^2 + dz^2));
                end
                
                RY1 = [cos(theta1) 0 -sin(theta1)
                       0           1 0
                       sin(theta1) 0 cos(theta1)];
                RZ2 = [cos(psi2) -sin(psi2) 0
                       sin(psi2) cos(psi2)  0
                       0         0          1];

                node_global = (RZ2*RY1*node_global.').';
                
                % perform translation
                node_global(:,1) = obj.node_i.x*ones(nn, 1) + node_global(:, 1);
                node_global(:,2) = obj.node_i.y*ones(nn, 1) + node_global(:, 2);
                node_global(:,3) = obj.node_i.z*ones(nn, 1) + node_global(:, 3);
                
            % initialize left and right
            cur_left_node = obj.node_i;
            cur_left_pos = 1;
            cur_right_node = obj.node_j;
            cur_right_pos = nn;
            
            % create column face nodes and elements
            if ~isempty(obj.cflri)
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                cfi = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(cfi);
                
                if ~isempty(obj.node_rigid_fix)
                    db.addFix( OpenSees.model.constraint.fix(cfi, obj.node_rigid_fix) );
                end
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, cfi, sec_meta.A, obj.Es*obj.rsf, sec_meta.Iy, obj.geom_transf_rig, obj.Gs*obj.rsf, sec_meta.J, sec_meta.Ix);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_left_node = cfi;
            end
                
            if ~isempty(obj.cflrj)
                cur_right_pos = cur_right_pos - 1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                cfj = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(cfj);
                
                if ~isempty(obj.node_rigid_fix)
                    db.addFix( OpenSees.model.constraint.fix(cfj, obj.node_rigid_fix) );
                end
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, cfj, sec_meta.A, obj.Es*obj.rsf, sec_meta.Iy, obj.geom_transf_rig, obj.Gs*obj.rsf, sec_meta.J, sec_meta.Ix);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_right_node = cfj;
            end
            
            % create column-face-spring dummy nodes and elements
            if any(ismember(p.UsingDefaults, 'spring_mat_i')) == 0 && ~isempty(p.Results.spring_mat_i)
                obj.spring_mat_i = p.Results.spring_mat_i;
                
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                i_dum = OpenSees.model.node(new_node_tag, cur_left_node.x, cur_left_node.y, cur_left_node.z);
                db.addNode(i_dum);
                
                if ~isempty(obj.node_rigid_fix)
                    db.addFix( OpenSees.model.constraint.fix(i_dum, obj.node_rigid_fix) );
                end
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                obj.spring_ele_i = OpenSees.model.element.zeroLength(new_ele_tag, cur_left_node, i_dum, obj.spring_mat_i, 1:6, 'x', [dx dy dz], 'yp', obj.vert_vec);
                if any(ismember(p.UsingDefaults, 'spring_flag_i')) == 0
                    obj.spring_flag_i = p.Results.spring_flag_i;
                    obj.spring_ele_i.flag = obj.spring_flag_i;
                end
                db.addElement(obj.spring_ele_i);
                
                cur_left_node = i_dum;
            end
            
            if any(ismember(p.UsingDefaults, 'spring_mat_j')) == 0 && ~isempty(p.Results.spring_mat_j)
                obj.spring_mat_j = p.Results.spring_mat_j;
                
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                j_dum = OpenSees.model.node(new_node_tag, cur_right_node.x, cur_right_node.y, cur_right_node.z);
                db.addNode(j_dum);
                
                if ~isempty(obj.node_rigid_fix)
                    db.addFix( OpenSees.model.constraint.fix(j_dum, obj.node_rigid_fix) );
                end
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                obj.spring_ele_j = OpenSees.model.element.zeroLength(new_ele_tag, cur_right_node, j_dum, obj.spring_mat_j, 1:6, 'x', -[dx dy dz], 'yp', obj.vert_vec);
                if any(ismember(p.UsingDefaults, 'spring_flag_j')) == 0
                    obj.spring_flag_j = p.Results.spring_flag_j;
                    obj.spring_ele_j.flag = obj.spring_flag_j;
                end
                db.addElement(obj.spring_ele_j);
                
                cur_right_node = j_dum;
            end
            
            % create additional offset nodes and elements
            if ~isempty(obj.lri)
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                off_i = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1),node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(off_i);
                
                if ~isempty(obj.node_rigid_fix)
                    db.addFix( OpenSees.model.constraint.fix(off_i, obj.node_rigid_fix) );
                end
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, off_i, sec_meta.A, obj.Es*obj.rsf, sec_meta.Iy, obj.geom_transf_rig, obj.Gs*obj.rsf, sec_meta.J, sec_meta.Ix);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_left_node = off_i;
            end

            if ~isempty(obj.lrj)
                cur_right_pos = cur_right_pos-1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                off_j = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(off_j);
                
                if ~isempty(obj.node_rigid_fix)
                    db.addFix( OpenSees.model.constraint.fix(off_j, obj.node_rigid_fix) );
                end
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, off_j, sec_meta.A, obj.Es*obj.rsf, sec_meta.Iy, obj.geom_transf_rig, obj.Gs*obj.rsf, sec_meta.J, sec_meta.Ix);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_right_node = off_j;
            end
            
            % create beam-column element
            new_ele_tag = db.getEleTag(cur_left_node.tag);
%             obj.bc_ele = OpenSees.model.element.forceBeamColumn(new_ele_tag, cur_left_node, cur_right_node, obj.geom_transf, obj.sec, 'maxIters', 300, 'np', 5, 'mass', obj.mass_dens, 'tol', 1.0e-12);
            obj.bc_ele = OpenSees.model.element.forceBeamColumn(new_ele_tag, cur_left_node, cur_right_node, obj.geom_transf, obj.sec, 'np', 5, 'mass', obj.mass_dens);
            db.addElement(obj.bc_ele);
            obj.line_ele = vertcat(obj.line_ele, obj.bc_ele);

        end
        
    end
    
end