function create_ppt_animation(time, ColIdxs, y1, y1std, y2, y2std, y3, y3std, y4, y4std, colors, ylabeltxt, titletxt, prefix, export)

%% Define Figure Settings
fig_height = 15;  % cm
fig_width = 15;   % cm
figFileType = ".png";

%% Create Figures
for i = ColIdxs
    ymin = min([y1(:,i) y2(:,i) y3(:,i) y4(:,i)], [], "all");
    ymax = max([y1(:,i) y2(:,i) y3(:,i) y4(:,i)], [], "all");
    for frame = 1:4
        fig = figure;
        set(gcf,"Units","centimeters")                                          % cm units for position
        set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
        grid on
        hold on
        if(frame > 0)
            plot_mean_std(time,y1(:,i),y1std(:,i),colors(1,:), 4)
        end
        if(frame > 1)
            plot_mean_std(time,y2(:,i),y2std(:,i),colors(2,:), 4)
        end
        if(frame > 2)
            plot_mean_std(time,y3(:,i),y3std(:,i),colors(3,:), 4)
        end
        if(frame > 3)
            plot_mean_std(time,y4(:,i),y4std(:,i),colors(4,:), 4)
        end
        % legend(["","tracking","", "generic", "", "personal", "", "Falisse2022"],"Location","best")
        xlabel("Gait Cycle [-]")
        xlim([0 1])
        ylim([ymin ymax])
        ylabel(ylabeltxt(i))
        % title(strrep(titletxt(i),"_"," "))
    
        % figure settings
        set(findall(fig,'-property','FontSize'),'FontSize',18)                  % font size
        set(0,"DefaultFigureColor","w")                                         % white background
        set(0,"defaulttextinterpreter","tex")                                   % tex style font
        set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
        set(gca,"Units","centimeters")                                          % cm units for position
        set(gca,"Position",[2.5 2.5 fig_width-3.5 fig_height-3.5])              % axes position (x, y, w, h)
        hold off
        % axis tight
    
        if(export)
            figName = prefix + titletxt(i) + "_frame" + frame + figFileType;
            exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
        end
    
    end
end

end