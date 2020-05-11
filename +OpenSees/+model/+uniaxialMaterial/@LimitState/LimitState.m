classdef LimitState < OpenSees.model.uniaxialMaterial
    
    properties
        
        format = '% 0.6f';
        format_array = ' %0.5f';
        
        % required
        sp;         % 3-element array
        sn;         % 3-element array
        ep;         % 3-element array
        en;         % 3-element array
        pinchX;
        pinchY;
        damage;     % 2-element array
        beta;
        curve;
        
    end
    
    methods
       
        function obj = LimitState(tag, sp, sn, ep, en, pinchX, pinchY, damage, beta, curve)
            
            p = inputParser;
            addRequired(p, 'tag');
            addRequired(p, 'sp');
            addRequired(p, 'sn');
            addRequired(p, 'ep');
            addRequired(p, 'en');
            addRequired(p, 'pinchX');
            addRequired(p, 'pinchY');
            addRequired(p, 'damage');
            addRequired(p, 'beta');
            addRequired(p, 'curve');
            parse(p, tag, sp, sn, ep, en, pinchX, pinchY, damage, beta, curve);
            
            % store variables
            obj.tag = tag;
            obj.sp = sp;
            obj.sn = sn;
            obj.ep = ep;
            obj.en = en;
            obj.pinchX = pinchX;
            obj.pinchY = pinchY;
            obj.damage = damage;
            obj.beta = beta;
            obj.curve = curve;
            
            % command line open
            obj.cmdLine = ['uniaxialMaterial LimitState ' num2str(tag) ' ' ...
                           num2str(obj.sp(1), obj.format) ' ' num2str(obj.ep(1), obj.format) ' ' ...
                           num2str(obj.sp(2), obj.format) ' ' num2str(obj.ep(2), obj.format) ' ' ...
                           num2str(obj.sp(3), obj.format) ' ' num2str(obj.ep(3), obj.format) ' ' ...
                           num2str(obj.sn(1), obj.format) ' ' num2str(obj.en(1), obj.format) ' ' ...
                           num2str(obj.sn(2), obj.format) ' ' num2str(obj.en(2), obj.format) ' ' ...
                           num2str(obj.sn(3), obj.format) ' ' num2str(obj.en(3), obj.format) ' ' ...
                           num2str(obj.pinchX, obj.format) ' ' num2str(obj.pinchY, obj.format) ' ' ...
                           num2str(obj.damage(1), obj.format) ' ' num2str(obj.damage(2), obj.format) ' ' ...
                           num2str(obj.beta, obj.format) ' ' ...
                           num2str(obj.curve.tag) ' ' num2str(obj.curve.type)];
                       
        end
        
    end
    
end
        