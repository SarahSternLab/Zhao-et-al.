function PlotNPFeed_SingleSession()

    load('data_NPFeed_SingleSession.mat')
    
    figure;
    plot(T, Right_Event*1, 'r|', MarkerSize=20); hold on;
    plot(T_RightNPPellet, ones(numel(T_RightNPPellet),1)*1, 'b|', MarkerSize=10);
    plot(T, Left_Event*1.2, 'r|', MarkerSize=20);
    plot(T_LeftNPPellet, ones(numel(T_LeftNPPellet),1)*1.2, 'b|', MarkerSize=10);
    hold off;
    
    ylim([0.8 1.4]);
    yticks(1:0.2:1.2); 
    yticklabels({ 'Right NPFeed','Left NPFeed'});
    xlabel('Time (minutes)');
    
end