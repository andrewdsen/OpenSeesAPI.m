% The Node recorder type records the response of a number of nodes at every converged step. Only
% file output is supported. See syntax below for supported features.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Node_Recorder
%
% tcl syntax:
% recorder Node <-file $fileName> <-precision $nSD> <-timeSeries $tsTag> <-time> <-dT $deltaT> ...
% <-node $node1 $node2 ...> -dof ($dof1 $dof2 ...) $respType'
%
% MATLAB syntax:
%

classdef Node < OpenSees
    
    properties
        
        fileName       % file name for recorder output without extension
        nSD = [];      % number of significant digits (optional)
        ts = [];       % time series object (optional)
        time = 0;      % places domain time in first entry of each data line (optional)
        deltaT = [];   % time interval for recording...will record when next is deltaT greater than
                       % the last recorder step (optional)
        node = [];     % array of node objects to record (optional)
        dof = [];      % array of dofs to record (optional)
        respType = {}; % cell array of response types to record:
                       % | disp           disp
                       % | vel            velocity
                       % | accel          acceleration
                       % | incrDisp       incremental displacement
                       % | "eigen i"      eigenvector for mode i
                       % | reaction       nodal reaction
                       % | rayleighForces damping forces
        
    end
    
    methods
        
        function obj = Node(fileName,varargin)
            
            p = inputParser;
            addRequired(p,'fileName',@ischar);
            addOptional(p,'nSD',obj.nSD);
            addOptional(p,'ts',obj.ts);
            addOptional(p,'time',obj.time);
            addOptional(p,'deltaT',obj.time);
            addOptional(p,'node',obj.node);
            addOptional(p,'dof',obj.dof);
            addOptional(p,'respType',obj.respType);
            parse(p,fileName,varargin{:});
            
            % store variables
            obj.fileName = fileName;
            
            % command line open
            obj.cmdLine = ['recorder Node -file ' obj.fileName '.out'];
            
            if any(ismember(p.UsingDefaults,'nSD')) == 0
     
                % store variables
                obj.nSD = p.Results.nSD;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -precision ' num2str(obj.nSD)];
                
            end
            
            if any(ismember(p.UsingDefaults,'ts')) == 0
                
                % store variables
                obj.ts = p.Results.ts;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -timeSeries ' num2str(obj.ts.tag)];
                
            end
            
            if any(ismember(p.UsingDefaults,'time')) == 0 && p.Results.time == true
                
                % store variables
                obj.time = p.Results.time;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -time'];
                
            end
            
            if any(ismember(p.UsingDefaults,'deltaT')) == 0
                
                % store variables
                obj.deltaT = p.Results.deltaT;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -dT ' num2str(obj.deltaT)];
                
            end
            
            if any(ismember(p.UsingDefaults,'node')) == 0
                
                % store variables
                obj.node = p.Results.node;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -node'];
                for ii = 1:length(obj.node)
                   
                    obj.cmdLine = [obj.cmdLine ' ' num2str(obj.node(ii).tag)];
                    
                end
                
            end
            
            if any(ismember(p.UsingDefaults,'dof')) == 0
                
                % store variables
                obj.dof = p.Results.dof;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -dof ' num2str(obj.dof)];
                
            end
            
            if any(ismember(p.UsingDefaults,'respType')) == 0
                
                % store variables
                obj.respType = p.Results.respType;
                
                % command line add
                for ii = 1:length(obj.respType)
                   
                    obj.cmdLine = [obj.cmdLine ' ' obj.respType{ii}];
                    
                end
                
            end
        end
        
    end
    
end
            
            
            
