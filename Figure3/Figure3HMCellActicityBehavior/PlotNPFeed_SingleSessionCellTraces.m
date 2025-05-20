function PlotNPFeed_SingleSessionCellTraces()

    load("data_NPFeed_SingleSessionCellTraces.mat")
    
    figure
    subplot(2,1,1);
    plot(T_LeftNP,  ones(numel(T_LeftNP), 1)*0.5, 'c|', MarkerSize=8); hold on;
    plot(T_RightNP, ones(numel(T_RightNP),1)*0.5, 'b|', MarkerSize=8);
    plot(T_Pellet,  ones(numel(T_Pellet), 1)*0.5, 'r|', MarkerSize=8);
    ylim([0.5,1.5]);
    set(gca, 'color', 'none');
    set(gca,'XColor', 'none','YColor','none')
    
    WT_HM = subplot(2,1,2);
    imagesc(T,1:size(Insc_Trace_Norm_Selec,1) ,Insc_Trace_Norm_Selec);clim([-4 4]);
    WT_HM.Position = WT_HM.Position + [0 WT_HM.Position(2) 0 0];
    ax = gca; axPosOriginal = ax.Position;
    colorbar
    ax.Position = axPosOriginal;
    xlabel('Time (seconds)')
    ylabel('Cell ID')

end