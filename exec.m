classdef exec
    
    properties
        
        db      % database object
        OSver   % OpenSees version
        batch_mod % string to append to run().bat
        
    end
    
    methods
        
        function obj = exec(db,OSver,batch_mod)
            
            obj.db = db;
            obj.OSver = OSver;
            
            if nargin == 3
                obj.batch_mod = batch_mod;
                batch_name = ['run' batch_mod '.bat'];
            else
                batch_name = 'run.bat';
            end
            
            fileID = fopen(db.fileName,'w+');
            fprintf(fileID,db.script);
            fprintf(fileID,['\nputs "analysis of model ' db.title ' complete"\nwipe;\nexit;']);
            fclose(fileID);
            
            batch = fopen(batch_name,'w+');
            if strcmp(obj.OSver,'reg')
                fprintf(batch,['OpenSees ' db.fileName]);
            elseif strcmp(obj.OSver,'SP')
                fprintf(batch,['OpenSeesSP ' db.fileName]);
            elseif strcmp(obj.OSver, 'SP_new')
                fprintf(batch,['OpenSeesSP_new ' db.fileName]);
            elseif strcmp(obj.OSver,'MP')
                fprintf(batch,['OpenSeesMP ' db.fileName]);
            end 
            fclose(batch);
            analysis_tic = tic;
            eval(['! ' batch_name]);
            eval(['delete ' batch_name]);
            toc(analysis_tic);
            
        end
        
        
    end
    
end
