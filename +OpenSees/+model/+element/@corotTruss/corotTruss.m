classdef corotTruss < OpenSees.model.element
    
    properties
        
        format = '% 0.7f';
       
        iNode = [];
        jNode = [];
        A = [];
        mat = [];
        
    end
    
    methods
        
        function obj = corotTruss(tag, iNode, jNode, A, mat)
           
            % store variables
            obj.tag = tag;
            obj.iNode = iNode;
            obj.jNode = jNode;
            obj.A = A;
            obj.mat = mat;
            
            % command line open
            obj.cmdLine = ['element corotTruss ' num2str(obj.tag) ' ' ...
                           num2str(obj.iNode.tag) ' ' ...
                           num2str(obj.jNode.tag) ' ' ...
                           num2str(obj.A, obj.format) ' ' ...
                           num2str(obj.mat.tag)];
            
        end
        
    end
    
end