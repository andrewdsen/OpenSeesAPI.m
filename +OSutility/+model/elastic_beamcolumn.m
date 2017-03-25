classdef elastic_beamcolumn < handle
   
    properties
        
        % required
        db              % database instance
        node_i          % node object at end i
        node_j          % node object at end j
        A               % gross area
        E               % elastic modulus
        G               % shear modulus
        J               % torsional constant
        Iy              % moment of inertia about local y-axis
        Iz              % moment of inertia about local z-axis
        geom_transf     % geometric tansfer object
        
        % optional
        offset_i = 0;   % rigid offset length at end i
        offset_j = 0;   % rigid offset length at end j
        rsf = 1.0e4;    % rigid scale factor
        fixity_i = 0;   % rigid offset connection fixity at end i
        fixity_j = 0;   % rigid offset connection fixity at end j
        
        % output
        main_ele;
        
    end
    
    methods
       
        function obj = elastic_beamcolumn(db, node_i, node_j, A, E, G, J, Iy, Iz, geom_transf, varargin)
            
            p = inputParser;
            addRequired(p, 'db');
            addRequired(p, 'node_i');
            addRequired(p, 'node_j');
            addRequired(p, 'A');
            addRequired(p, 'E');
            addRequired(p, 'G');
            addRequired(p, 'J');
            addRequired(p, 'Iy');
            addRequired(p, 'Iz');
            addRequired(p, 'geom_transf');
            addOptional(p, 'offset_i', obj.offset_i);
            addOptional(p, 'offset_j', obj.offset_j);
            addOptional(p, 'fixity_i', obj.fixity_i);
            addOptional(p, 'fixity_j', obj.fixity_j);
            addOptional(p, 'rsf', obj.rsf);
            parse(p, db, node_i, node_j, A, E, G, J, Iy, Iz, geom_transf, varargin{:});
            
            % store variables
            obj.node_i = node_i;
            obj.node_j = node_j;
            obj.A = A;
            obj.E = E;
            obj.G = G;
            obj.J = J;
            obj.Iy = Iy;
            obj.Iz = Iz;
            obj.geom_transf = geom_transf;
            
            % calculate beam-column length
            dx = obj.node_j.x - obj.node_i.x;
            dy = obj.node_j.y - obj.node_i.y;
            dz = obj.node_j.z - obj.node_i.z;
            L = sqrt(dx^2 + dy^2 + dz^2); % beam-column work-point-to-work-point length
            
            if any(ismember(p.UsingDefaults, 'offset_i')) == 0
                obj.offset_i = p.Results.offset_i;
                if obj.offset_i > 0
                    offset_pos_i = obj.offset_i;
                else
                    offset_pos_i = [];
                end
            end
            if any(ismember(p.UsingDefaults, 'offset_j')) == 0
                obj.offset_j = p.Results.offset_j;
                if obj.offset_j > 0
                    offset_pos_j = L - obj.offset_j;
                else
                    offset_pos_j = [];
                end
            end
            
            if any(ismember(p.UsingDefaults, 'fixity_i')) == 0
                obj.fixity_i = p.Results.fixity_i;
            end
            if any(ismember(p.UsingDefaults, 'fixity_j')) == 0
                obj.fixity_j = p.Results.fixity_j;
            end
            if any(ismember(p.UsingDefaults, 'rsf')) == 0
                obj.rsf = p.Results.rsf;
            end
            
            % calculate local nodal coordinates
            node_local.x = [0 offset_pos_i offset_pos_j L];
            nn = length(node_local.x);

            node_local.y = zeros(1, nn);
            node_local.z = zeros(1, nn);
            
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
            if obj.offset_i > 0
                cur_left_pos = cur_left_pos + 1;
 
                new_node_tag = db.getNodeTag(cur_left_node.tag);
                node_rig_i = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                db.addNode(node_rig_i);
                
                new_ele_tag = db.getEleTag(cur_left_node.tag);
                db.addElement( OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, node_rig_i, obj.A, obj.E*obj.rsf, obj.Iz, obj.geom_transf, obj.G*obj.rsf, obj.J, obj.Iy) );

                cur_left_node = node_rig_i;
                
                if obj.fixity_i == 0
                    new_node_tag = db.getNodeTag(cur_left_node.tag);
                    node_dum_i = OpenSees.model.node(new_node_tag, node_global(cur_left_pos, 1), node_global(cur_left_pos, 2), node_global(cur_left_pos, 3));
                    db.addNode(node_dum_i);
                    db.addFix( OpenSees.model.constraint.equalDOF(cur_left_node, node_dum_i, [1:3 4  5 6]) );
                    cur_left_node = node_dum_i;                    
                end
            end
            
            if obj.offset_j > 0
                cur_right_pos = cur_right_pos - 1;
 
                new_node_tag = db.getNodeTag(cur_right_node.tag);
                node_rig_j = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                db.addNode(node_rig_j);
                
                new_ele_tag = db.getEleTag(cur_right_node.tag);
                db.addElement( OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_right_node, node_rig_j, obj.A, obj.E*obj.rsf, obj.Iz, obj.geom_transf, obj.G*obj.rsf, obj.J, obj.Iy) );

                cur_right_node = node_rig_j;
                
                if obj.fixity_j == 0
                    new_node_tag = db.getNodeTag(cur_right_node.tag);
                    node_dum_j = OpenSees.model.node(new_node_tag, node_global(cur_right_pos, 1), node_global(cur_right_pos, 2), node_global(cur_right_pos, 3));
                    db.addNode(node_dum_j);
                    db.addFix( OpenSees.model.constraint.equalDOF(cur_right_node, node_dum_j, [1:3 4 5 6]) );
                    cur_right_node = node_dum_j;                    
                end
            end
            
            new_ele_tag = db.getEleTag(cur_left_node.tag);
            obj.main_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_left_node, cur_right_node, obj.A, obj.E, obj.Iz, obj.geom_transf, obj.G, obj.J, obj.Iy);
            db.addElement(obj.main_ele);
            
        end
        
    end
    
end