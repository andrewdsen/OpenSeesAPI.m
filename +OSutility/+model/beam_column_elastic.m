classdef beam_column_elastic < handle
    
properties

    % required
    db = [];            % database instance
    sec_meta = [];      % section metadata
    geom_transf = [];   % geometric transformation
    node_i = [];        % beam-column start node
    node_j = [];        % beam-column end node

    % optional
    Es = 29000;
    Gs = 10000;
    node_tag_mod = 0;
    ele_tag = 1;
    vert_vec = [0 0 1]; % vector defining vertical axis in global coordinates
    fixity = 'fixed';   % end fixity

    % output
    bc_ele = [];

end

methods

    function obj = beam_column_elastic(db, sec_meta, geom_transf, node_i, node_j, varargin)

        p = inputParser;
        addRequired(p, 'db');
        addRequired(p, 'sec_meta');
        addRequired(p, 'geom_transf');
        addRequired(p, 'node_i');
        addRequired(p, 'node_j');
        addOptional(p, 'Es', obj.Es);
        addOptional(p, 'Gs', obj.Gs);
        addOptional(p, 'node_tag_mod', obj.node_tag_mod);
        addOptional(p, 'ele_tag', obj.ele_tag);
        addOptional(p, 'vert_vec', obj.vert_vec);
        addOptional(p, 'fixity', obj.fixity);
        parse(p, db, sec_meta, geom_transf, node_i, node_j, varargin{:});

        % store variables
        obj.db = db;
        obj.sec_meta = sec_meta;
        obj.geom_transf = geom_transf;
        obj.node_i = node_i;
        obj.node_j = node_j;

        if any(ismember(p.UsingDefaults, 'Es')) == 0
            obj.Es = p.Results.Es;
        end
        if any(ismember(p.UsingDefaults, 'Gs')) == 0
            obj.Gs = p.Results.Gs;
        end
        if any(ismember(p.UsingDefaults, 'node_tag_mod')) == 0
            obj.node_tag_mod = p.Results.node_tag_mod;
        end
        if any(ismember(p.UsingDefaults, 'ele_tag')) == 0
            obj.ele_tag = p.Results.ele_tag;
        else
            obj.ele_tag = obj.node_i.tag;
        end
        if any(ismember(p.UsingDefaults, 'vert_vec')) == 0
            obj.vert_vec = p.Results.vert_vec;
        end
        if any(ismember(p.UsingDefaults, 'fixity')) == 0
            obj.fixity = p.Results.fixity;
        end
        
        if strcmp(obj.fixity, 'pinned')
            new_node_tag = db.getNodeTag(obj.node_i.tag + obj.node_tag_mod);
            cur_node_i = OpenSees.model.node(new_node_tag, obj.node_i.x, obj.node_i.y, obj.node_i.z);
            db.addNode(cur_node_i);

            new_node_tag = db.getNodeTag(obj.node_j.tag + obj.node_tag_mod);
            cur_node_j = OpenSees.model.node(new_node_tag, obj.node_j.x, obj.node_j.y, obj.node_j.z);
            db.addNode(cur_node_j);
            
            db.addFix( OpenSees.model.constraint.equalDOF(obj.node_i, cur_node_i, [1 2 3 4 6]) );
            db.addFix( OpenSees.model.constraint.equalDOF(obj.node_j, cur_node_j, [1 2 3 4 6]) );
        elseif strcmp(obj.fixity, 'i_pinned')
            new_node_tag = db.getNodeTag(obj.node_i.tag + obj.node_tag_mod);
            cur_node_i = OpenSees.model.node(new_node_tag, obj.node_i.x, obj.node_i.y, obj.node_i.z);
            db.addNode(cur_node_i);
            
            db.addFix( OpenSees.model.constraint.equalDOF(obj.node_i, cur_node_i, [1 2 3 4 6]) );
            cur_node_j = obj.node_j;
        elseif strcmp(obj.fixity, 'j_pinned')
            new_node_tag = db.getNodeTag(obj.node_j.tag + obj.node_tag_mod);
            cur_node_j = OpenSees.model.node(new_node_tag, obj.node_j.x, obj.node_j.y, obj.node_j.z);
            db.addNode(cur_node_j);
            
            db.addFix( OpenSees.model.constraint.equalDOF(obj.node_j, cur_node_j, [1 2 3 4 6]) );
            cur_node_i = obj.node_i;
        else
            cur_node_i = obj.node_i;
            cur_node_j = obj.node_j;
        end
        
        new_ele_tag = db.getEleTag(obj.ele_tag);
        obj.bc_ele = OpenSees.model.element.elasticBeamColumn(new_ele_tag, cur_node_i, cur_node_j, obj.sec_meta.A, obj.Es, obj.sec_meta.Iy, obj.geom_transf, obj.Gs, obj.sec_meta.J, obj.sec_meta.Ix);
        db.addElement(obj.bc_ele);
        
    end
    
end

end