classdef showModel < handle

    properties
    
        node         % node instance to be plotted
        element      % element connectivity matrix for nodes
        nodeSize     % size of node marker in plot
        lwidth       % size of line width in plot
        setAxis      % axis for plot
        
    end

    methods
        
        function obj = showModel(node,element,nodeSize,lwidth,setAxis)
            
            obj.node = node;
            obj.element = element;
            obj.nodeSize = nodeSize;
            obj.lwidth = lwidth;
            obj.setAxis= setAxis;
            
        end
               
        function timeHistory(obj,recFile,setPause)
            
            inp = load([recFile '.out']);
            numSteps = size(inp,1);
            numNodes = length(obj.node);

            if isempty(obj.node(1).z)

                % 2D case
                for ii = 1:numNodes
                    orig.node(ii).x = obj.node(ii).x;
                    orig.node(ii).y = obj.node(ii).y;
                end
                
                for ii = 1:numSteps

                    for jj = 1:numNodes
                        
                        obj.node(jj).x = orig.node(jj).x + inp(ii,1+3*jj-2);
                        obj.node(jj).y = orig.node(jj).y + inp(ii,1+3*jj-1);
                        
                    end
                    
                    obj.draw(obj.node,obj.element,obj.nodeSize,obj.lwidth,obj.setAxis);
                    pause(setPause);

                end
                
            else
                
                % 3D case
                for ii = 1:numNodes
                    orig.node(ii).x = obj.node(ii).x;
                    orig.node(ii).y = obj.node(ii).y;
                    orig.node(ii).z = obj.node(ii).z;
                end
                
                for ii = 1:numSteps

                    for jj = 1:numNodes
                        
                        obj.node(jj).x = orig.node(jj).x + inp(ii,1+6*jj-5);
                        obj.node(jj).y = orig.node(jj).y + inp(ii,1+6*jj-4);
                        obj.node(jj).z = orig.node(jj).z + inp(ii,1+6*jj-3);
                        
                    end
                    
                    obj.draw(obj.node,obj.element,obj.nodeSize,obj.lwidth,obj.setAxis);
                    pause(setPause);

                end
                
            end
            
        end
        
        function station1(obj,nodeDispRec,storyDispRec,driftHeight,baseShearRec,column,brace,braceDispRec,braceForceRec,expData,hAxis,bAxis,colMAxis,brAxis,dispAmp)
           
            addpath ../../../dataAnalysis/commonFunctions/export_fig/

            % define plot characteristics
            markSize = 1.5;
            lwidth = 1;
            fontSize = 10;
            
                % colors
                blue = 1*[0.15 0.4 1];
                green = 0.5*[0.4 1 0.3];
                red = 1*[1 0.2 0.1];
                white = 1*[1 1 1];
                gray = 0.6*[1 1 1];
                black = 0*[1 1 1];
                cOrder = [0         0.4470    0.7410
                          0.8500    0.3250    0.0980
                          0.9290    0.6940    0.1250
                          0.4940    0.1840    0.5560
                          0.4660    0.6740    0.1880
                          0.3010    0.7450    0.9330
                          0.6350    0.0780    0.1840];
               set(0,'defaultAxesColorOrder',cOrder([1 2 4 3],:),...
                     'defaultAxesLineStyleOrder','-|:',...
                     'defaultAxesLineWidth',lwidth,...
                     'defaultAxesFontSize',fontSize,...
                     'defaultAxesColor','none');
            
            % load numerical results
            inpDisp = load([nodeDispRec '.out']);
            inpStoryDisp = load([storyDispRec '.out']);
            inpBaseShear = -load([baseShearRec '.out']);
            for ii = 1:length(brace)
                
                inpBrDisp(ii,:,:) = load([braceDispRec{ii} '.out']);
                inpBrForce(ii,:,:) = load([braceForceRec{ii} '.out']);
                
            end
            inpColLoad = load([column '.out']);
            
            ns = min([size(inpDisp,1) size(inpStoryDisp,1) size(inpBaseShear,1)]);
            nn = length(obj.node);
            nel = length(obj.element);
            
            % load experimental results
            exp = load(expData);
            
            % store original node locations
            origLoc = [obj.node.x; obj.node.y; obj.node.z];
            
            % calculate story drifts
            rDisp(:,1) = mean(inpStoryDisp(:,4:5),2);
            sDisp(:,1) = mean(inpStoryDisp(:,2:3),2);
            sDisp(:,2) = rDisp - sDisp(:,1);
            rDrift = rDisp/driftHeight(2)*100; 
            sDrift(:,1) = sDisp(:,1)/driftHeight(1)*100;
            sDrift(:,2) = sDisp(:,2)/(driftHeight(2) - driftHeight(1))*100;
            
            % calculate base shear
            baseShear = sum(inpBaseShear(:,2:end),2);
            
            % calculate column loads
            ColV = inpColLoad(:,1+6:12:end);
            ColP = inpColLoad(:,2+6:12:end);
            ColM = -inpColLoad(:,6+6:12:end);
            
            % calculate brace lengths
            for ii = 1:length(brace)

                Lbr(ii) = sqrt((brace(ii).brNode(1).x - brace(ii).brNode(end).x)^2 + ...
                               (brace(ii).brNode(1).y - brace(ii).brNode(end).y)^2);
                for jj = 1:ns
                
                    Lbrp = sqrt(((brace(ii).brNode(1).x+inpBrDisp(ii,jj,1)) - (brace(ii).brNode(end).x+inpBrDisp(ii,jj,3)))^2 + ...
                                ((brace(ii).brNode(1).y+inpBrDisp(ii,jj,2)) - (brace(ii).brNode(end).y+inpBrDisp(ii,jj,4)))^2);
                    BrDef(ii,jj) = (Lbrp - Lbr(ii))/Lbr(ii)*100;
                    BrForce(ii,jj) = -inpBrForce(ii,jj,1);
                    
                end
                
            end
            
            % store element connectivity
            conn = zeros(nel,2);
            for ii = 1:nel
                conn(ii,:) = [find(obj.node == obj.element(ii).iNode) find(obj.node == obj.element(ii).jNode)];
            end
            
            % calculate new node locations and draw         
            figure(1);
            panel1  = axes('Units','inches','Position',[0.5 5 5 4.5]);
            panel2  = axes('Units','inches','Position',[-1 5.75 4 3]);
            panel3  = axes('Units','inches','Position',[4 5.75 4 3]);
            panel4  = axes('Units','inches','Position',[8.25 6.5 3 2]);
            panel5  = axes('Units','inches','Position',[8.25 3.5 3 2]);
            panel6  = axes('Units','inches','Position',[8.25 0.5 3 2]);
            panel7  = axes('Units','inches','Position',[4 3.5 3 2]);
            panel8  = axes('Units','inches','Position',[4 0.5 3 2]);
            panel9  = axes('Units','inches','Position',[1 0.5 2 2]);
            panel10 = axes('Units','inches','Position',[1 3.5 2 2]);

            counter = 0;
%             for ii = 1:60:ns
            for ii = ns
                for jj = 1:nn

                    newLoc(jj).x = origLoc(1,jj) + inpDisp(ii,1+3*jj-2)*dispAmp;
                    newLoc(jj).y = origLoc(2,jj) + inpDisp(ii,1+3*jj-1)*dispAmp;
                    newLoc(jj).z = origLoc(3,jj) + inpDisp(ii,1+3*jj)*dispAmp;

                end
                
                counter = counter+1;
                figName = num2str(counter,'%04g');
                
                % perspective view
                set(gcf,'CurrentAxes',panel1);
                    plot3([newLoc.x],[newLoc.y],[newLoc.z],'ko',...
                          'MarkerSize',markSize,...
                          'MarkerFaceColor','k',...
                          'LineWidth',lwidth); hold on;
                      
                    for kk = 1:nel
                        
                        if obj.element(kk).tag >= 5e8
                            lwMod = 2;
                        else
                            lwMod = 1;
                        end
                        plot3([newLoc(conn(kk,:)).x],[newLoc(conn(kk,:)).y],[newLoc(conn(kk,:)).z],'k-',...
                              'LineWidth',lwidth*lwMod);
                          
                    end

                    axis(obj.setAxis);
                    set(gca,'Color','none',...
                            'Visible','off',...
                            'DataAspectRatio',[1 1 1],...
                            'PlotBoxAspectRatio',[3 4 4],...
                            'View',[55 40],...
                            'CameraUpVector',[0 1 0],...
                            'Projection','perspective');

                hold off;
                
                % out-of-plane view
                set(gcf,'CurrentAxes',panel2);
                    plot([newLoc.z],[newLoc.y],'ko',...
                         'MarkerSize',markSize,...
                         'MarkerFaceColor','k',...
                         'LineWidth',lwidth); hold on;
                     
                    for kk = 1:nel
                        
                        if obj.element(kk).tag >= 5e8
                            lwMod = 2;
                        else
                            lwMod = 1;
                        end
                        plot([newLoc(conn(kk,:)).z],[newLoc(conn(kk,:)).y],'k-',...
                              'LineWidth',lwidth*lwMod);
                          
                    end
                     
                    axis(obj.setAxis);
                    set(gca,'Color','none',...
                            'Visible','off',...
                            'DataAspectRatio',[1 1 1]);
                hold off;
                
                % in-plane view
                set(gcf,'CurrentAxes',panel3);
                    plot([newLoc.x],[newLoc.y],'ko',...
                         'MarkerSize',markSize,...
                         'MarkerFaceColor','k',...
                         'LineWidth',lwidth); hold on;
                     
                    for kk = 1:nel
                        
                        if obj.element(kk).tag >= 5e8
                            lwMod = 2;
                        else
                            lwMod = 1;
                        end
                        plot([newLoc(conn(kk,:)).x],[newLoc(conn(kk,:)).y],'k-',...
                              'LineWidth',lwidth*lwMod);
                          
                    end
                     
                    axis(obj.setAxis);
                    set(gca,'Color','none',...
                            'Visible','off',...
                            'DataAspectRatio',[1 1 1]);
                hold off;
                
                % base shear-roof drift hysteresis
                set(gcf,'CurrentAxes',panel4);
                    plot(exp.roofDrift,exp.baseShear,'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(rDrift(1:ii),baseShear(1:ii),'-','LineWidth',lwidth);
                    plot(rDrift(ii),baseShear(ii),'o','LineWidth',lwidth,'MarkerSize',markSize);                    
                    
                    xlabel('Roof drift (%)');
                    ylabel('Base shear (kN)');
                    
                    leg1 = legend('Experimental','OpenSees','Location','SouthEast');
                    set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(hAxis)
                    
                hold off;

                % base shear-2F drift hysteresis
                set(gcf,'CurrentAxes',panel5);
                    plot(exp.sDrift(:,2),exp.baseShear,'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(sDrift(1:ii,2),baseShear(1:ii),'-','LineWidth',lwidth);
                    plot(sDrift(ii,2),baseShear(ii),'o','LineWidth',lwidth,'MarkerSize',markSize);                    
                    
                    xlabel('Second story drift (%)');
                    ylabel('Base shear (kN)');
                    
                    leg1 = legend('Experimental','OpenSees','Location','SouthEast');
                    set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(hAxis)
                    
                hold off;
                
                % base shear-1F drift hysteresis
                set(gcf,'CurrentAxes',panel6);
                    plot(exp.sDrift(:,1),exp.baseShear,'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(sDrift(1:ii,1),baseShear(1:ii),'-','LineWidth',lwidth);
                    plot(sDrift(ii,1),baseShear(ii),'o','LineWidth',lwidth,'MarkerSize',markSize);                    
                    
                    xlabel('First story drift (%)');
                    ylabel('Base shear (kN)');
                    
                    leg1 = legend('Experimental','OpenSees','Location','SouthEast');
                    set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(hAxis)
                    
                hold off;
                
                % 2F beam deflection-2F drift hysteresis
                bNode = findobj(obj.node,'x',0,'y',3297*2);
                bInd = find([obj.node.tag] == bNode.tag);
                set(gcf,'CurrentAxes',panel7);
                    plot(exp.sDrift(:,2),exp.beamVert(:,2),'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(sDrift(1:ii,2),inpDisp(1:ii,1+bInd*3-1),'-','LineWidth',lwidth);
                    plot(sDrift(ii,2),inpDisp(ii,1+bInd*3-1),'o','LineWidth',lwidth,'MarkerSize',markSize);                    
                    
                    xlabel('Second story drift (%)');
                    ylabel('Beam midspan deflection (mm)');
                    
                    leg1 = legend('Experimental','OpenSees','Location','SouthEast');
                    set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(bAxis)
                    
                hold off;
                
                % 1F beam deflection-1F drift hysteresis
                bNode = findobj(obj.node,'x',0,'y',3297);
                bInd = find([obj.node.tag] == bNode.tag);
                set(gcf,'CurrentAxes',panel8);
                    plot(exp.sDrift(:,1),exp.beamVert(:,1),'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(sDrift(1:ii,1),inpDisp(1:ii,1+bInd*3-1),'-','LineWidth',lwidth);
                    plot(sDrift(ii,1),inpDisp(ii,1+bInd*3-1),'o','LineWidth',lwidth,'MarkerSize',markSize);                    
                    
                    xlabel('First story drift (%)');
                    ylabel('Beam midspan deflection (mm)');
                    
                    leg1 = legend('Experimental','OpenSees','Location','SouthEast');
                    set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(bAxis)
                    
                hold off;
                                
%                 % brace force-deflection hystereses
%                     
%                     % 1F
%                     set(gcf,'CurrentAxes',panel9);
%                     plot(BrDef(2,1:ii),BrForce(2,1:ii),'-','Color',cOrder(1,:),'LineWidth',lwidth); hold on;
%                     plot(BrDef(2,ii),BrForce(2,ii),'o','Color',cOrder(1,:),'LineWidth',lwidth,'MarkerSize',markSize);                    
% %                     plot(BrDef(2,1:ii),BrForce(2,1:ii),'-','Color',cOrder(2,:),'LineWidth',lwidth);
% %                     plot(BrDef(2,ii),BrForce(2,ii),'o','Color',cOrder(2,:),'LineWidth',lwidth,'MarkerSize',markSize); 
%                     
%                     xlabel('Brace axial deformation (%)');
%                     ylabel('Brace axial force (kN)');
%                     
% %                     leg1 = legend('South','North','Location','SouthEast');
% %                     set(leg1,'FontSize',fontSize,'Box','off');
%                     set(gca,'Color','none');
%                     axis(brAxis)
%                     
%                     hold off;
%                     
%                     % 2F
%                     set(gcf,'CurrentAxes',panel10);
%                     plot(BrDef(3,1:ii),BrForce(3,1:ii),'-','Color',cOrder(1,:),'LineWidth',lwidth); hold on;
%                     plot(BrDef(3,ii),BrForce(3,ii),'o','Color',cOrder(1,:),'LineWidth',lwidth,'MarkerSize',markSize);                    
% %                     plot(BrDef(4,1:ii),BrForce(4,1:ii),'-','Color',cOrder(2,:),'LineWidth',lwidth);
% %                     plot(BrDef(4,ii),BrForce(4,ii),'o','Color',cOrder(2,:),'LineWidth',lwidth,'MarkerSize',markSize); 
%                     
%                     xlabel('Brace axial deformation (%)');
%                     ylabel('Brace axial force (kN)');
%                     
% %                     leg1 = legend('South','North','Location','SouthEast');
% %                     set(leg1,'FontSize',fontSize,'Box','off');
%                     set(gca,'Color','none');
%                     axis(brAxis)
%                     
%                     hold off;

                % column moment-story drift hystereses
                    
                    % 1F
                    set(gcf,'CurrentAxes',panel9);
                    plot(exp.sDrift(:,1),exp.Vcol(:,1),'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(sDrift(1:ii,1),ColV(1:ii,1) + ColV(1:ii,5),'-','LineWidth',lwidth);
                    plot(sDrift(ii,1),ColV(ii,1) + ColV(ii,5),'o','LineWidth',lwidth,'MarkerSize',markSize);
                    
                    xlabel('Story drift (%)');
                    ylabel('Column shear (kN)');
                    
%                     leg1 = legend('South','North','Location','SouthEast');
%                     set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(colMAxis)
                    
                    hold off;
                    
                    % 2F
                    set(gcf,'CurrentAxes',panel10);
                    plot(exp.sDrift(:,2),exp.Vcol(:,2),'-','Color',gray,'LineWidth',lwidth); hold on;
                    plot(sDrift(1:ii,2),ColV(1:ii,3) + ColV(1:ii,7),'-','LineWidth',lwidth);
                    plot(sDrift(ii,2),ColV(ii,3) + ColV(ii,7),'o','LineWidth',lwidth,'MarkerSize',markSize);
                    
                    xlabel('Story drift (%)');
                    ylabel('Column shear (kN)');
                    
%                     leg1 = legend('South','North','Location','SouthEast');
%                     set(leg1,'FontSize',fontSize,'Box','off');
                    set(gca,'Color','none');
                    axis(colMAxis)
                    
                    hold off;


                set(gcf,'Units','inches',...
                        'Position',[-17 1 12 9]);
                drawnow;
                
                figLoc = ['./animate/'];
                figFile = [figLoc,figName];
                export_fig(figFile,'-r300','-transparent','-nocrop','-pdf');

            end
            
        end
        
    end
    
    methods (Static)
        
        function draw(node,element,nodeSize,lwidth,setAxis)
            
            if isempty(node(1).z)     
                
                % 2D case
                figure(1); 
                for ii = 1:length(node)
                    
                    plot(node(ii).x,node(ii).y,'ko',...
                         'MarkerSize',nodeSize,...
                         'MarkerFaceColor','k',...
                         'LineWidth',lwidth); hold on;
                     
                end
                
                for ii = 1:length(element)
                    
                    plot([element(ii).iNode.x element(ii).jNode.x],...
                         [element(ii).iNode.y element(ii).jNode.y],...
                         'k-','LineWidth',lwidth);
                    
                end
                
                xlabel('x position');
                ylabel('y position');
                set(gca,'Color','none');
                axis(setAxis);
                
                hold off;
                
            else
                
                % 3D case
                figure(1);
                for ii = 1:length(node)
                    
                    plot3(node(ii).x,node(ii).y,node(ii).z,'ko',...
                          'MarkerSize',nodeSize,...
                          'MarkerFaceColor','k',...
                          'LineWidth',lwidth); hold on;
                      
                end
                
                for ii = 1:length(element)
                    
                    plot3([element(ii).iNode.x element(ii).jNode.x],...
                          [element(ii).iNode.y element(ii).jNode.y],...
                          [element(ii).iNode.z element(ii).jNode.z],...
                          'k-','LineWidth',lwidth);
                    
                end
                
                xlabel('x position');
                ylabel('y position');
                zlabel('z position');
                set(gca,'Color','none');
                axis(setAxis);
                
                hold off;
                
            end     
            
        end
        
    end
    
end
