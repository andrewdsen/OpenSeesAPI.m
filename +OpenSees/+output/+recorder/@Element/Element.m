% The Element recorder type records the response of a number of elements at every converged step. 
% The response recorded is element-dependent and also depends on the arguments which are passed to 
% the setResponse() element method.
%
% Ref: http://opensees.berkeley.edu/wiki/index.php/Element_Recorder
%
% tcl syntax:
% recorder Element <-file $fileName> <-xml $fileName> <-binary $fileName> <-precision $nSD> <-time>
% <-closeOnWrite> <-dT $deltaT> <-ele ($ele1 $ele2 ...)> <-eleRange $startEle $endEle> 
% <-region $regTag> $arg1 $arg2 ...
%
% MATLAB syntax:
% 

classdef Element < OpenSees
    
    properties
              
        format = '%0.5f';   % string format
        
        % optional
        fileName = [];      % file name for recorder output without extension
        nSD = [];           % number of significant digits
        time = 0;           % places domain time in first entry of each data line
        closeOnWrite = 0;   % using this option will instruct the recorder to invoke a close on the
                            % data handler after every timestep; if this is a file it will close the
                            % file on every step and then reopen it for the next step; this greatly
                            % slows the execution time but useful if you need to monitor the data
                            % during the analysis
        deltaT = [];        % time interval for recording; will record when next is deltaT greater
                            % than the last recorder step
        ele = [];           % array of element objects to record
        respType = {};      % cell array of response types to record:
                            % | depends on element/section/material used       
        
    end
    
    methods
        
        function obj = Element(varargin)
           
            p = inputParser;
            addOptional(p,'fileName',obj.fileName);
            addOptional(p,'nSD',obj.nSD);
            addOptional(p,'time',obj.time);
            addOptional(p,'closeOnWrite',obj.closeOnWrite);
            addOptional(p,'deltaT',obj.time);
            addOptional(p,'ele',obj.ele);
            addOptional(p,'respType',obj.respType);
            parse(p,varargin{:});
            
            % command line open
            obj.cmdLine = ['recorder Element'];
            
            if any(ismember(p.UsingDefaults,'fileName')) == 0
     
                % store variables
                obj.fileName = p.Results.fileName;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -file ' obj.fileName '.out'];
                
            end
            
            if any(ismember(p.UsingDefaults,'nSD')) == 0
     
                % store variables
                obj.nSD = p.Results.nSD;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -precision ' num2str(obj.nSD)];
                
            end
            
            if any(ismember(p.UsingDefaults,'time')) == 0 && p.Results.time == true
                
                % store variables
                obj.time = p.Results.time;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -time'];
                
            end
                
            if any(ismember(p.UsingDefaults,'closeOnWrite')) == 0 && p.Results.closeOnWrite == true
                
                % store variables
                obj.closeOnWrite = p.Results.closeOnWrite;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -closeOnWrite'];
                
            end
            
            if any(ismember(p.UsingDefaults,'deltaT')) == 0
                
                % store variables
                obj.deltaT = p.Results.deltaT;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -dT ' num2str(obj.deltaT,obj.format)];
                
            end
            
            if any(ismember(p.UsingDefaults,'ele')) == 0
                
                % store variables
                obj.ele = p.Results.ele;
                
                % command line add
                obj.cmdLine = [obj.cmdLine ' -ele'];
                for ii = 1:length(obj.ele)
                   
                    obj.cmdLine = [obj.cmdLine ' ' num2str(obj.ele(ii).tag)];
                    
                end
                
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

