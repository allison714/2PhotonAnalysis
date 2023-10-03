smooth_movie = movmean(filtered_movie,11,3);

figure, clf, hold on, box on;
vidName= 'File.mp4';
vidfile = VideoWriter(vidName,'MPEG-4');
open(vidfile);

plth = imagesc(flipud(smooth_movie(:,:,1)), [10,100]);

% set color limits or whatever you want

ax=gca;
ax.FontSize=20;
xlim([0,size(smooth_movie,2)])
ylim([0,size(smooth_movie,1)])
xlabel('x')
ylabel('y')

writeVideo(vidfile,getframe(gcf));

for i=2:size(smooth_movie,3)
    % loop through entire simulation
    set(plth,'CData',flipud(smooth_movie(:,:,i)))
%     pause(0.2)
    writeVideo(vidfile,getframe(gcf));
end
close(vidfile)