classdef Pinching4 < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '% 0.5f';
        format_array = ' %0.5f';
        
        % required
        ePf         % force points on positive response envelope
        ePd         % deformation points on positive response envelope
        rDispP      % ratio of deformation at which reloading occurs to the maximum historic deformation demand
        rForceP     % ratio of force at which reloading begins to force corresponding to the maximum historic deformation demand
        uForceP     % ratio of strength developed upon unloading from negative load to the maximum strength developed under monotonic loading
        gK          % values controlling cyclic degradation model for unloading stiffness degradation
        gD          % values controlling cyclic degradation model for reloading stiffness degradation
        gF          % values controlling cyclic degradation model for strength degradation
        gE          % value used to define maximum energy dissipation under cyclic loading; total energy dissipation capacity is defined as this factor × energy dissipated under monotonic loading
        dmgType     % string to indicate type of damage ('cycle' or 'energy')
        
        % optional
        eNf         % force points on negative response envelope
        eNd         % deformation points on negative response envelope
        rDispN      % ratio of deformation at which reloading occurs to the minimum historic deformation demand
        rForceN     % ratio of force at which reloading begins to force corresponding to the minimum historic deformation demand
        uForceN     % ratio of strength developed upon unloading from positive load to the minimum strength developed under monotonic loading
        
    end
    
    methods
       
        function obj = Pinching4(tag, ePf, ePd, rDispP, rForceP, uForceP, gK, gD, gF, gE, dmgType, varargin)
            
            p = inputParser;
            addRequired(p, 'tag');
            addRequired(p, 'ePf');
            addRequired(p, 'ePd');
            addRequired(p, 'rDispP');
            addRequired(p, 'rForceP');
            addRequired(p, 'uForceP');
            addRequired(p, 'gK');
            addRequired(p, 'gD');
            addRequired(p, 'gF');
            addRequired(p, 'gE');
            addRequired(p, 'dmgType');
            addOptional(p, 'eNf', obj.eNf);
            addOptional(p, 'eNd', obj.eNd);
            addOptional(p, 'rDispN', obj.rDispN);
            addOptional(p, 'rForceN', obj.rForceN);
            addOptional(p, 'uForceN', obj.uForceN);
            parse(p, tag, ePf, ePd, rDispP, rForceP, uForceP, gK, gD, gF, gE, dmgType, varargin{:});
            
            % store variables
            obj.tag = tag;
            obj.ePf = ePf;
            obj.ePd = ePd;
            obj.rDispP = rDispP;
            obj.rForceP = rForceP;
            obj.uForceP = uForceP;
            obj.gK = gK;
            obj.gD = gD;
            obj.gF = gF;
            obj.gE = gE;
            obj.dmgType = dmgType;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial Pinching4 ' num2str(tag) ' ' ...
                           num2str(obj.ePf(1), obj.format) ' ' num2str(obj.ePd(1), obj.format) ' ' ...
                           num2str(obj.ePf(2), obj.format) ' ' num2str(obj.ePd(2), obj.format) ' ' ...
                           num2str(obj.ePf(3), obj.format) ' ' num2str(obj.ePd(3), obj.format) ' ' ...
                           num2str(obj.ePf(4), obj.format) ' ' num2str(obj.ePd(4), obj.format)];
                       
            % command line add            
            if (any(ismember(p.UsingDefaults, 'eNf')) == 0 && any(ismember(p.UsingDefaults, 'eNd')) == 0)
                obj.eNf = p.Results.eNf;
                obj.eNd = p.Results.eNd;
                
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.eNf(1), obj.format) ' ' num2str(obj.eNd(1), obj.format) ' ' ...
                               num2str(obj.eNf(2), obj.format) ' ' num2str(obj.eNd(2), obj.format) ' ' ...
                               num2str(obj.eNf(3), obj.format) ' ' num2str(obj.eNd(3), obj.format) ' ' ...
                               num2str(obj.eNf(4), obj.format) ' ' num2str(obj.eNd(4), obj.format)];
            end
            
            obj.cmdLine = [obj.cmdLine ' ' ...
                           num2str(obj.rDispP, obj.format) ' ' ...
                           num2str(obj.rForceP, obj.format) ' ' ...
                           num2str(obj.uForceP, obj.format)];
                       
            if (any(ismember(p.UsingDefaults, 'rDispN')) == 0 && any(ismember(p.UsingDefaults, 'rForceN')) == 0 && any(ismember(p.UsingDefaults, 'uForceN')) == 0)
                obj.rDispN = p.Results.rDispN;
                obj.rForceN = p.Results.rForceN;
                obj.uForceN = p.Results.uForceN;
                
                obj.cmdLine = [obj.cmdLine ' ' ...
                               num2str(obj.rDispN, obj.format) ' ' ...
                               num2str(obj.rForceN, obj.format) ' ' ...
                               num2str(obj.uForceN, obj.format)];                
            end
            
            obj.cmdLine = [obj.cmdLine ' ' ...
                           num2str(obj.gK, obj.format_array) ' ' ...
                           num2str(obj.gD, obj.format_array) ' ' ...
                           num2str(obj.gF, obj.format_array) ' ' ...
                           num2str(obj.gE, obj.format) ' ' ...
                           '"' obj.dmgType '"'];
            
        end
        
    end
    
end
        