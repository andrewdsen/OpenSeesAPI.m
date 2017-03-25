classdef database < matlab.mixin.Copyable
   
    properties
        
        title               % model title
        author              % model author
        fileName            % model file name without extension (default is title)
        script              % model script
        model               % model intializer
        node                % array of nodes in model
        fix                 % array of nodal fixity in model
        mass                % array of nodal masses in model
        equalDOF            % array of internodal constraints in model
        material            % array of materials in model
        section             % array of sections in model
        geomTransf          % arary of geometric transformations in model
        element             % array of elements in model
        timeSeries          % time series used by analysis
        load                % load used by analysis
        recorder            % array of recorders used in analysis
        analysis            % array of analyses to run
        
        damp_node           % array of nodes for mass-based ralyeigh damping
        damp_ele            % array of elements for stiffness-based rayleigh damping
        nodeTagList         % array of node tags used (for ensuring unique numbering)
        eleTagList          % array of element tags used (for ensuring unique numbering)
        x_grid
        y_grid
        z_grid
        
    end

    methods
        
        % constructor
        function obj = database(title,author,fileName)
            
            % store variables
            obj.title = title;
            obj.author = author;
            obj.script = ['### Title:  ' obj.title '\n',...
                          '### Author: ' obj.author '\n'];
            obj.fileName = fileName;
            
        end

        % functions to add commands to database
        function obj = addNode(obj,Node)           
            obj.node = vertcat(obj.node,Node);
            obj.nodeTagList = vertcat(obj.nodeTagList,Node.tag);
        end
        
        function obj = addFix(obj,Fix)
            obj.fix = vertcat(obj.fix,Fix);
        end
        
        function obj = addMass(obj,Mass)
            obj.mass = vertcat(obj.mass,Mass);
        end
        
        function obj = addEqualDOF(obj,EqualDOF)
            obj.equalDOF = vertcat(obj.equalDOF,EqualDOF);
        end
        
        function obj = addMaterial(obj,Material)
            obj.material = vertcat(obj.material,Material);
        end
        
        function obj = addSection(obj,Section)
            obj.section = vertcat(obj.section,Section);
        end
        
        function obj = addGeomTransf(obj,GeomTransf)
            obj.geomTransf = vertcat(obj.geomTransf,GeomTransf);
        end
        
        function obj = addElement(obj,Element)
            obj.element = vertcat(obj.element,Element);
            obj.eleTagList = vertcat(obj.eleTagList,Element.tag);
        end
        
        function obj = addTimeSeries(obj,N,TimeSeries)
            obj.timeSeries = vertcat(obj.timeSeries,{N,TimeSeries});
        end
        
        function obj = addLoad(obj,N,Load)
            obj.load = vertcat(obj.load,{N,Load});
        end
        
        function obj = addRecorder(obj,Recorder)
            obj.recorder = vertcat(obj.recorder,Recorder);
        end
        
        function obj = addAnalysis(obj,N,Analysis)
            obj.analysis = vertcat(obj.analysis,{N,Analysis});
        end
        
        % adds cmd command to tcl file
        function addCmd(obj,cmd)

            % if nothing's there, do nothing
            if isempty(cmd)
                return
            end
            
            tempLine = cmd.cmdLine;

            if ~strcmp(cmd.options,'')
                tempLine = [tempLine ' ' cmd.options];
            end
            tempLine = [tempLine ';'];
            
            if ~strcmp(cmd.notes,'')
                tempLine = [tempLine ' # ' cmd.notes];                
            end
            
            obj.script = [obj.script tempLine '\n'];
            
        end
        
        % adds array of cmd commands to tcl file
        function addCmdArray(obj,cmdArray)
           
            for ii = 1:length(cmdArray)
                obj.addCmd( cmdArray(ii) );
            end
            
        end
        
        % adds break to tcl file
        function addBreak(obj,head)
            obj.script = [obj.script '\n## ' head '\n'];
        end
        
        % writes tcl file
        function write(obj)
            
            obj.fileName = [obj.fileName '.tcl'];
           
            obj.addCmd( OpenSees.misc.wipe );
            
            obj.addBreak('Model');
                obj.addCmd( obj.model );
                
            obj.addBreak('Nodes');
                obj.addCmdArray( obj.node );
                obj.addCmdArray( obj.fix );
                obj.addCmdArray( obj.equalDOF );
                obj.addCmdArray( obj.mass );
                
            obj.addBreak('Materials');
                obj.addCmdArray( obj.material );
            
            obj.addBreak('Sections');
                obj.addCmdArray( obj.section );
            
            obj.addBreak('Geometric Transformations');
                obj.addCmdArray( obj.geomTransf );
                
            obj.addBreak('Elements');
                obj.addCmdArray( obj.element );     
                              
            obj.addBreak('Recorders');
                obj.addCmdArray( obj.recorder );
                
            obj.addBreak('Analysis');
                n = unique( cell2mat(obj.analysis(:, 1)) );
                for ii = 1:length(n)
                    obj.addBreak(['Analysis ' num2str(n(ii))]);
                    for jj = 1:size(obj.timeSeries, 1)
                        if obj.timeSeries{jj, 1}  == n(ii)
                            obj.addCmd( obj.timeSeries{jj, 2} );
                        end
                    end
                    for jj = 1:size(obj.load, 1)
                        if obj.load{jj, 1}  == n(ii)
                            obj.addCmd( obj.load{jj, 2} );
                        end
                    end
                    for jj = 1:size(obj.analysis, 1)
                        if obj.analysis{jj, 1}  == n(ii)
                            obj.addCmd( obj.analysis{jj, 2} );
                        end
                    end
                end
                
        end
        
        function tag = get_node_tag(obj, node_x, node_y, node_z)
           
            [~, near_x] = min(abs(obj.x_grid - node_x));
            [~, near_y] = min(abs(obj.y_grid - node_y));
            [~, near_z] = min(abs(obj.z_grid - node_z));
            start_tag = str2double(['1' num2str(near_z, '%02g') num2str(near_x, '%02g') num2str(near_y-1, '%02g') '001']);
            while any(obj.nodeTagList == start_tag)
                start_tag = start_tag + 1;
            end
            tag = start_tag;
            
        end
        
        function tag = getNodeTag(obj,startTag)
           
            while any(obj.nodeTagList == startTag)
                startTag = startTag+1;
            end
            tag = startTag;
            
        end
        
         function tag = getEleTag(obj,startTag)
           
            while any(obj.eleTagList == startTag)
                startTag = startTag+1;
            end
            tag = startTag;
            
        end       
    end
    
end