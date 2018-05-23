classdef exec_par
    
properties

    db          % array of database objects
    osver       % string specifying OpenSees version
    id          % cell array of strings to append to run.sh
    add
    folder

end

methods

    function obj = exec_par(db, osver, id, add, folder)

        obj.db = db;
        obj.osver = osver;
        obj.id = id;
        obj.add = add;
        obj.folder = folder;

        batch_name = [obj.folder 'run_par_' obj.add];
        batch = fopen(batch_name, 'w+');
        for ii = 1:length(obj.id)

            fileID = fopen([obj.folder obj.db(ii).fileName], 'w+');
            fprintf(fileID, obj.db(ii).script);
            fprintf(fileID, ['\nputs "analysis of model ' obj.db(ii).title ' complete"\nwipe;\nexit;']);
            fclose(fileID);
            switch obj.osver
                case 'reg'
                    fprintf(batch, ['OpenSees ' obj.db(ii).fileName '\n']);
                case 'SP'
                    fprintf(batch, ['OpenSeesSP ' obj.db(ii).fileName '\n']);
                case 'MP'
                    fprintf(batch, ['OpenSeesMP ' obj.db(ii).fileName '\n']);
            end
            
        end

        fclose(batch);

    end


end
    
end
