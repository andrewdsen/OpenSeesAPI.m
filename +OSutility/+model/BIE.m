classdef BIE < handle
    
    properties
        
        % required
        db                  % database instance
        sec                 % brace section instance (fracture section)
        sec_n               % brace section instance (nonfracture section)
        geom_transf         % brace geometric transformation instance
        geom_transf_rig     % brace geometric transformation instance for rigid elements
        node_i              % node instance at work point i
        node_j              % node instance at work point j
        
        % optional
        ecc = 0;    % intentional eccentricity
        nel = 16;   % number of brace elements
        np = 5;     % number of integration points per element
        bc_type = 'disp';   % beam-column element type (options: disp or force)
        imp_type = 'sin';   % initial imperfection shape (option: sin)
        imp_amp = 1/500;    % initial imperfection amplitude
        imp_dir = 'OOP';    % initial imperfection and eccentricity direction        
        l_gp_offset         % scalar or 2-element array of frame-to-gusset offsets
        l_br_offset         % scalar or 2-element array of brace-to-gusset offsets
        gp_i_mat_array      % array of materials to define gusset plate at end i
        gp_j_mat_array      % array of materials to define gusset plate at end j
        rsf = 1e4;          % rigid scale factor for offsets
        vert_vec = [0 1 0]; % vector defining vertical axis in global coordinates
        mass_dens = 0       % element mass density (per unit length)
        
        % output
        spring_ele_i
        spring_ele_j
        node_br_i
        node_br_j
        bc_ele = OpenSees;
        line_ele = [];
        
    end
    
    methods
        
        function obj = BIE(db, sec, sec_n, geom_transf, geom_transf_rig, node_i, node_j, varargin)
            
            p = inputParser;
            addRequired(p, 'db');
            addRequired(p, 'sec');
            addRequired(p, 'sec_n');
            addRequired(p, 'geom_transf');
            addRequired(p, 'geom_transf_rig');
            addRequired(p, 'node_i');
            addRequired(p, 'node_j');
            addOptional(p, 'ecc', obj.ecc);
            addOptional(p, 'nel', obj.nel);
            addOptional(p, 'np', obj.np);
            addOptional(p, 'bc_type', obj.bc_type);
            addOptional(p, 'imp_type', obj.imp_type);
            addOptional(p, 'imp_amp', obj.imp_amp);
            addOptional(p, 'imp_dir', obj.imp_dir);
            addOptional(p, 'l_gp_offset', obj.l_gp_offset);
            addOptional(p, 'l_br_offset', obj.l_br_offset);
            addOptional(p, 'gp_i_mat_array', obj.gp_i_mat_array);
            addOptional(p, 'gp_j_mat_array', obj.gp_j_mat_array);
            addOptional(p, 'rsf', obj.rsf);
            addOptional(p, 'vert_vec', obj.vert_vec);
            addOptional(p, 'mass_dens', obj.mass_dens);
            parse(p, db, sec, sec_n, geom_transf, geom_transf_rig, node_i, node_j, varargin{:});
            
            %%%%%%
            %%% store variables
            %%%%%%
            
            obj.sec = sec;
            obj.sec_n = sec_n;
            obj.geom_transf = geom_transf;
            obj.geom_transf_rig = geom_transf_rig;
            obj.node_i = node_i;
            obj.node_j = node_j;
            
            if any(ismember(p.UsingDefaults, 'ecc')) == 0
                obj.ecc = p.Results.ecc;
            end
            if any(ismember(p.UsingDefaults, 'nel')) == 0
                obj.nel = p.Results.nel;
            end
            if any(ismember(p.UsingDefaults, 'np')) == 0
                obj.np = p.Results.np;
            end
            if any(ismember(p.UsingDefaults, 'bc_type')) == 0
                obj.bc_type = p.Results.bc_type;
            end
            if any(ismember(p.UsingDefaults, 'imp_type')) == 0
                obj.imp_type = p.Results.imp_type;
            end
            if any(ismember(p.UsingDefaults, 'imp_amp')) == 0
                obj.imp_amp = p.Results.imp_amp;
            end
            if any(ismember(p.UsingDefaults, 'imp_dir')) == 0
                obj.imp_dir = p.Results.imp_dir;
            end
            if any(ismember(p.UsingDefaults, 'gp_i_mat_array')) == 0
                if length(p.Results.gp_i_mat_array) ~= 6 && ~isempty(p.Results.gp_i_mat_array)
                    error('Syntax error in BIE constructor: length(gp_i_mat_array) != 6');
                else
                    obj.gp_i_mat_array = p.Results.gp_i_mat_array;
                end
            end
            if any(ismember(p.UsingDefaults, 'gp_j_mat_array')) == 0
                if length(p.Results.gp_j_mat_array) ~= 6 && ~isempty(p.Results.gp_j_mat_array)
                    error('Syntax error in BIE constructor: length(gp_j_mat_array) != 6');
                else
                    obj.gp_j_mat_array = p.Results.gp_j_mat_array;
                end
            end
            if any(ismember(p.UsingDefaults, 'rsf')) == 0
                obj.rsf = p.Results.rsf;
            end
            if any(ismember(p.UsingDefaults, 'vert_vec')) == 0
                obj.vert_vec = p.Results.vert_vec;
            end
            if any(ismember(p.UsingDefaults, 'mass_dens')) == 0
                obj.mass_dens = p.Results.mass_dens;
            end
            
            %%%%%%
            %%% determine brace geometry
            %%%%%%
            
            % calculate beam-column length
            dx = obj.node_j.x - obj.node_i.x;
            dy = obj.node_j.y - obj.node_i.y;
            dz = obj.node_j.z - obj.node_i.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % beam-column work point-to-work point length
            
            % calculate local nodal coordinates
            if any(ismember(p.UsingDefaults, 'l_gp_offset')) == 0
                if length(p.Results.l_gp_offset) == 1
                    obj.l_gp_offset = p.Results.l_gp_offset*[1 1];
                elseif length(p.Results.l_gp_offset) == 2
                    if size(p.Results.l_gp_offset, 1) == 2
                        obj.l_gp_offset = obj.l_gp_offset.';
                    else
                        obj.l_gp_offset = p.Results.l_gp_offset;
                    end
                else
                    error('Syntax error in BIE constructor: length(l_gp_offset) > 2');
                end
                l_gp_i_offset_loc = obj.l_gp_offset(1);
                l_gp_j_offset_loc = L - obj.l_gp_offset(2);
            else
                obj.l_gp_offset = [0 0];
                l_gp_i_offset_loc = [];
                l_gp_j_offset_loc = [];
            end
            if obj.l_gp_offset(1) == 0
                l_gp_i_offset_loc = [];
            end
            if obj.l_gp_offset(2) == 0
                l_gp_j_offset_loc = [];
            end
            
            if any(ismember(p.UsingDefaults, 'l_br_offset')) == 0
                if length(p.Results.l_br_offset) == 1
                    obj.l_br_offset = p.Results.l_br_offset*[1 1];
                elseif length(p.Results.l_br_offset) == 2
                    if size(p.Results.l_br_offset, 1) == 2
                        obj.l_br_offset = obj.l_br_offset.';
                    else
                        obj.l_br_offset = p.Results.l_br_offset;
                    end
                else
                    error('Syntax error in BIE constructor: length(l_br_offset) > 2');
                end
                l_br_i_offset_loc = sum([l_gp_i_offset_loc obj.l_br_offset(1)]);
                l_br_j_offset_loc = sum([l_gp_j_offset_loc -obj.l_br_offset(2)]);
            else
                obj.l_br_offset = [0 0];
                l_br_i_offset_loc = [];
                l_br_j_offset_loc = [];
            end
            if obj.l_br_offset(1) == 0
                l_br_i_offset_loc = [];
            end
            if obj.l_br_offset(2) == 0
                l_br_j_offset_loc = [];
            end
            
            L_clear = L - sum(obj.l_br_offset) - sum(obj.l_gp_offset);
            br_nat = linspace(0, L_clear, obj.nel+1);
            br_loc = br_nat + sum([obj.l_gp_offset(1) obj.l_br_offset(1)]);
            
            node_local.x = [0 l_gp_i_offset_loc l_br_i_offset_loc, ...
                            br_loc(2:end-1), ...
                            l_br_j_offset_loc l_gp_j_offset_loc L];
            
            nn = length(node_local.x);
            if strcmp(obj.imp_type, 'sin')
                imp_fun = @(x) L_clear*obj.imp_amp*sin(x*pi/L_clear); 
            elseif strcmp(obj.imp_type, 'cos')
                imp_fun = @(x) L_clear*obj.imp_amp/2*(1 - cos(x*2*pi/L_clear));
            end
            
            node_local.y = zeros(1, nn);
            node_local.z = zeros(1, nn);
            br_pos = find(ismember(round(node_local.x*1e8)/1e8, round(br_loc*1e8)/1e8));
            if strcmp(obj.imp_dir, 'OOP')
                if obj.vert_vec(3) == 1
                    node_local.y(br_pos) = node_local.y(br_pos) + imp_fun(br_nat) + obj.ecc; 
                else
                    node_local.z(br_pos) = node_local.z(br_pos) + imp_fun(br_nat) + obj.ecc;
                end
            elseif strcmp(obj.imp_dir, 'IP')
                if obj.vert_vec(3) == 1
                    node_local.z = node_local.z(br_pos) + imp_fun(br_nat) + obj.ecc;
                else
                    node_local.y = node_local.y(br_pos) + imp_fun(br_nat) + obj.ecc;
                end
            else
                error('Syntax error in BIE constructor: imp_dir not recognized');
            end
            
            % calculate global nodal coordinates
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
                node_global(:,1) = obj.node_i.x*ones(nn,1) + node_global(:,1);
                node_global(:,2) = obj.node_i.y*ones(nn,1) + node_global(:,2);
                node_global(:,3) = obj.node_i.z*ones(nn,1) + node_global(:,3);
                
            %%%%%%
            %%% create nodes and elements
            %%%%%%
            
            cur_left_node = obj.node_i;
            cur_left_pos = 1;
            cur_right_node = obj.node_j;
            cur_right_pos = nn;
            
            % create gusset-plate-offset nodes and elements
            if obj.l_gp_offset(1) > 0
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                node_gp_i_1 = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(node_gp_i_1);
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, node_gp_i_1, obj.sec.A, obj.sec.E*obj.rsf, obj.sec.Iz, obj.geom_transf_rig, obj.sec.G*obj.rsf, obj.sec.J, obj.sec.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);

                cur_left_node = node_gp_i_1;
            end
            
            if obj.l_gp_offset(2) > 0
                cur_right_pos = cur_right_pos - 1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                node_gp_j_1 = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(node_gp_j_1);
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, node_gp_j_1, obj.sec.A, obj.sec.E*obj.rsf, obj.sec.Iz, obj.geom_transf_rig, obj.sec.G*obj.rsf, obj.sec.J, obj.sec.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_right_node = node_gp_j_1;
            end
            
            % create gusset-plate nodes and elements
            if ~isempty(obj.gp_i_mat_array) 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                node_gp_i_2 = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(node_gp_i_2);
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                obj.spring_ele_i = OpenSees.model.element.zeroLength(new_ele_tag, cur_left_node, node_gp_i_2, obj.gp_i_mat_array, 1:6, 'x', -[dx dy dz], 'yp', obj.vert_vec);
                db.addElement(obj.spring_ele_i);

                cur_left_node = node_gp_i_2;
            end
            
            if ~isempty(obj.gp_j_mat_array) 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                node_gp_j_2 = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(node_gp_j_2);
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                obj.spring_ele_j = OpenSees.model.element.zeroLength(new_ele_tag, cur_right_node, node_gp_j_2, obj.gp_j_mat_array, 1:6, 'x', [dx dy dz], 'yp', obj.vert_vec);
                db.addElement(obj.spring_ele_j);

                cur_right_node = node_gp_j_2;
            end
            
            % create brace offset nodes and elements
            if obj.l_br_offset(1) > 0
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                obj.node_br_i = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(obj.node_br_i);
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, obj.node_br_i, obj.sec.A, obj.sec.E*obj.rsf, obj.sec.Iz, obj.geom_transf_rig, obj.sec.G*obj.rsf, obj.sec.J, obj.sec.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_left_node = obj.node_br_i;
            end
            
            if obj.l_br_offset(2) > 0
                cur_right_pos = cur_right_pos - 1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                obj.node_br_j = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(obj.node_br_j);
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, obj.node_br_j, obj.sec.A, obj.sec.E*obj.rsf, obj.sec.Iz, obj.geom_transf_rig, obj.sec.G*obj.rsf, obj.sec.J, obj.sec.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_right_node = obj.node_br_j;
            end
            
            % create brace nodes and elements
            for ii = 1:obj.nel
                cur_left_pos = cur_left_pos + 1;
                
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                if ii < obj.nel
                    node_br(ii) = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                    db.addNode(node_br(ii));
                    new_left_node = node_br(ii);
                elseif ii == obj.nel
                    new_left_node = cur_right_node;
                else
                    error('Exception error in BIE constructor at line 305');
                end                
                
                if ii <= obj.nel*1/4 || ii > obj.nel*3/4
                    cur_sec = obj.sec_n;
                else
                    cur_sec = obj.sec;
                end
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                if strcmp(obj.bc_type, 'disp')
                    obj.bc_ele(ii, 1) = OpenSees.model.element.dispBeamColumn(new_ele_tag, cur_left_node, new_left_node, obj.geom_transf, cur_sec, 'np', obj.np, 'massDens', obj.mass_dens);
                    db.addElement(obj.bc_ele(ii));
                elseif strcmp(obj.bc_type, 'force')
%                     obj.bc_ele(ii, 1) = OpenSees.model.element.forceBeamColumn(new_ele_tag, cur_left_node, new_left_node, obj.geom_transf, cur_sec, 'maxIters', 300, 'np', obj.np, 'tol', 1.0e-12, 'massDens', obj.mass_dens);
                    obj.bc_ele(ii, 1) = OpenSees.model.element.forceBeamColumn(new_ele_tag, cur_left_node, new_left_node, obj.geom_transf, cur_sec, 'np', obj.np, 'massDens', obj.mass_dens);
                    db.addElement(obj.bc_ele(ii));
                else
                    error('Syntax error in BIE constructor: bc_type not recognized');
                end
                
                if ii < obj.nel
                    cur_left_node = node_br(ii);
                end
                
                obj.line_ele = vertcat(obj.line_ele, obj.bc_ele);                
            end
            
        end
        
    end
    
end