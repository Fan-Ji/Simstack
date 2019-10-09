close(vw);
delete(vw);
vid.DiskLogger = [];
save(fullfile(saveDir,'metadata.mat'), 'out');
