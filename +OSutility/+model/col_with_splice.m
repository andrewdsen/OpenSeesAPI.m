classdef col_with_splice < handle
    
    properties
        
        % required
        db                  % database instance
        sec_below           % column section instance (below splice)
        sec_above           % column section instance (above splice)
        geom_transf         % brace geometric transformation instance
        node_i              % node instance at work point i
        node_j              % node instance at work point j
        splice_dist         % distance from work point to splice point
        splice_mat_array    % arary of materials to define splice behavior
        
        % optional
        nel = 16;           % number of brace elements
        np = 5;             % number of integration points per element
        bc_type = 'disp';   % beam-column element type (options: disp or force)
        imp_type = 'sin';   % initial imperfection shape (option: sin)
        imp_amp = 1/500;    % initial imperfection amplitude
        imp_dir = 'OOP';    % initial imperfection and eccentricity direction        
        l_bc_offset         % scalar or 2-element array of beam-column offsets
        l_gp_offset         % scalar or 2-element array of gusset-plate offsets
        rsf = 1e4;          % rigid scale factor for offsets
        horz_vec = [1 0 0]; % vector defining horizontal axis in global coordinates
        vert_vec = [0 0 1]; % vector defining vertical axis in global coordinates
        mass_dens = 0       % element mass density (per unit length)
                
        % output
        bc_ele = OpenSees;
        line_ele = [];    
        splice_ele
        
    end
    
    methods
        
        function obj = col_with_splice(db, sec_below, sec_above, geom_transf, node_i, node_j, splice_dist, splice_mat_array, varargin)
            
            p = inputParser;
            addRequired(p, 'db');
            addRequired(p, 'sec_below');
            addRequired(p, 'sec_above');
            addRequired(p, 'geom_transf');
            addRequired(p, 'node_i');
            addRequired(p, 'node_j');
            addRequired(p, 'splice_dist');
            addRequired(p, 'splice_mat_array');
            addOptional(p, 'nel', obj.nel);
            addOptional(p, 'np', obj.np);
            addOptional(p, 'bc_type', obj.bc_type);
            addOptional(p, 'imp_type', obj.imp_type);
            addOptional(p, 'imp_amp', obj.imp_amp);
            addOptional(p, 'imp_dir', obj.imp_dir);
            addOptional(p, 'l_bc_offset', obj.l_bc_offset);
            addOptional(p, 'l_gp_offset', obj.l_gp_offset);
            addOptional(p, 'rsf', obj.rsf);
            addOptional(p, 'horz_vec', obj.horz_vec);
            addOptional(p, 'vert_vec', obj.vert_vec);
            addOptional(p, 'mass_dens', obj.mass_dens);
            parse(p, db, sec_below, sec_above, geom_transf, node_i, node_j, splice_dist, splice_mat_array, varargin{:});
            
            %%%%%%
            %%% store variables
            %%%%%%
            
            obj.sec_below = sec_below;
            obj.sec_above = sec_above;
            obj.geom_transf = geom_transf;
            obj.node_i = node_i;
            obj.node_j = node_j;
            obj.splice_dist = splice_dist;
            obj.splice_mat_array = splice_mat_array;
            if length(obj.splice_mat_array) ~=6
                error('Syntax error in col_with_splice constructor: length(splice_mat_array) != 6');
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
            if any(ismember(p.UsingDefaults, 'rsf')) == 0
                obj.rsf = p.Results.rsf;
            end
            if any(ismember(p.UsingDefaults, 'horz_vec')) == 0
                obj.horz_vec = p.Results.horz_vec;
            end
            if any(ismember(p.UsingDefaults, 'vert_vec')) == 0
                obj.vert_vec = p.Results.vert_vec;
            end
            if any(ismember(p.UsingDefaults, 'mass_dens')) == 0
                obj.mass_dens = p.Results.mass_dens;
            end
            
            %%%%%%
            %%% determine column geometry
            %%%%%%
                        
            % calculate beam-column length
            dx = obj.node_j.x - obj.node_i.x;
            dy = obj.node_j.y - obj.node_i.y;
            dz = obj.node_j.z - obj.node_i.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % beam-column work point-to-work point length
            
            % calculate local nodal coordinates
            if any(ismember(p.UsingDefaults, 'l_bc_offset')) == 0
                if length(p.Results.l_bc_offset) == 1
                    obj.l_bc_offset = p.Results.l_bc_offset*[1 1];
                elseif length(p.Results.l_bc_offset) == 2
                    if size(p.Results.l_bc_offset, 1) == 2
                        obj.l_bc_offset = obj.l_bc_offset.';
                    else
                        obj.l_bc_offset = p.Results.l_bc_offset;
                    end
                else
                    error('Syntax error in col_with_splice constructor: length(l_bc_offset) > 2');
                end
                l_gp_i_offset_loc = obj.l_bc_offset(1);
                l_gp_j_offset_loc = L - obj.l_bc_offset(2);
            else
                obj.l_bc_offset = [0 0];
                l_gp_i_offset_loc = [];
                l_gp_j_offset_loc = [];
            end
            if obj.l_bc_offset(1) == 0
                l_gp_i_offset_loc = [];
            end
            if obj.l_bc_offset(2) == 0
                l_gp_j_offset_loc = [];
            end
            
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
                    error('Syntax error in col_with_splice constructor: length(l_gp_offset) > 2');
                end
                l_br_i_offset_loc = sum([l_gp_i_offset_loc obj.l_gp_offset(1)]);
                l_br_j_offset_loc = sum([l_gp_j_offset_loc -obj.l_gp_offset(2)]);
            else
                obj.l_gp_offset = [0 0];
                l_br_i_offset_loc = [];
                l_br_j_offset_loc = [];
            end
            if obj.l_gp_offset(1) == 0
                l_br_i_offset_loc = [];
            end
            if obj.l_gp_offset(2) == 0
                l_br_j_offset_loc = [];
            end
            
            L_clear = L - sum(obj.l_gp_offset) - sum(obj.l_bc_offset);
            br_nat = linspace(0, L_clear, obj.nel+1);
            br_loc = br_nat + sum([obj.l_bc_offset(1) obj.l_gp_offset(1)]);
            if splice_dist <= br_loc(1)
                error('Erorr in col_with_splice constructor: splice location is inside rigid offset zone - use something larger');
            else
                [~, splice_ind] = min(abs(br_loc - splice_dist));
                br_loc(splice_ind) = splice_dist;
            end
            
            node_local.x = [0 l_gp_i_offset_loc l_br_i_offset_loc, ...
                            br_loc(2:end-1), ...
                            l_br_j_offset_loc l_gp_j_offset_loc L];
            
            % TODO: figure out how to keep track of splice node, make dummy
            % node, and apply material
            
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
                    node_local.y(br_pos) = node_local.y(br_pos) + imp_fun(br_nat); 
                else
                    node_local.z(br_pos) = node_local.z(br_pos) + imp_fun(br_nat);
                end
            elseif strcmp(obj.imp_dir, 'IP')
                if obj.vert_vec(3) == 1
                    node_local.z = node_local.z(br_pos) + imp_fun(br_nat);
                else
                    node_local.y = node_local.y(br_pos) + imp_fun(br_nat);
                end
            else
                error('Syntax error in col_with_splice constructor: imp_dir not recognized');
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
            if obj.l_bc_offset(1) > 0
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                node_gp_i_1 = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(node_gp_i_1);
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, node_gp_i_1, obj.sec_below.A, obj.sec_below.E*obj.rsf, obj.sec_below.Iz, obj.geom_transf, obj.sec_below.G*obj.rsf, obj.sec_below.J, obj.sec_below.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);

                cur_left_node = node_gp_i_1;
            end
            
            if obj.l_bc_offset(2) > 0
                cur_right_pos = cur_right_pos - 1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                node_gp_j_1 = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(node_gp_j_1);
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, node_gp_j_1, obj.sec_above.A, obj.sec_above.E*obj.rsf, obj.sec_above.Iz, obj.geom_transf, obj.sec_above.G*obj.rsf, obj.sec_above.J, obj.sec_above.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_right_node = node_gp_j_1;
            end
            
            % create brace offset nodes and elements
            if obj.l_gp_offset(1) > 0
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                obj.node_br_i = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(obj.node_br_i);
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, obj.node_br_i, obj.sec_below.A, obj.sec_below.E*obj.rsf, obj.sec_below.Iz, obj.geom_transf, obj.sec_below.G*obj.rsf, obj.sec_below.J, obj.sec_below.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_left_node = obj.node_br_i;
            end
            
            if obj.l_gp_offset(2) > 0
                cur_right_pos = cur_right_pos - 1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                obj.node_br_j = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(obj.node_br_j);
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                cur_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, obj.node_br_j, obj.sec_above.A, obj.sec_above.E*obj.rsf, obj.sec_above.Iz, obj.geom_transf, obj.sec_above.G*obj.rsf, obj.sec_above.J, obj.sec_above.Iy);
                cur_ele.flag = 'rigid';
                db.addElement(cur_ele);
                
                obj.line_ele = vertcat(obj.line_ele, cur_ele);
                
                cur_right_node = obj.node_br_j;
            end
            
            % create brace nodes and elements
            cur_sec = obj.sec_below;
            for ii = 1:obj.nel
                if ii == splice_ind
                    new_node_tag = db.getNodeTag(cur_left_node.tag);
                    node_splice = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                    db.addNode(node_splice);
                    new_left_node = node_splice;
                    
                    new_ele_tag = db.getEleTag(cur_left_node.tag);
                    obj.splice_ele = OpenSees.model.element.zeroLength(new_ele_tag, cur_left_node, new_left_node, obj.splice_mat_array, 1:6, 'x', [dx dy dz], 'yp', obj.horz_vec);
                    db.addElement(obj.splice_ele);
                    
                    cur_left_node = new_left_node;
                    cur_sec = obj.sec_above;
                end                   
                
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
                
                if ii == splice_ind-1
                    
                elseif ii < obj.nel
                    cur_left_node = node_br(ii);
                end
                
                obj.line_ele = vertcat(obj.line_ele, obj.bc_ele);                
            end
            
        end
        
    end
    
end