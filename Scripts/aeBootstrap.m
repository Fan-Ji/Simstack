aeprm_Pump1Speed = 0.4;
aeprm_Pump2Speed = 0.2;
% recording params;
rpm = 400;
expId = 1;
totalFlow = 0.6;
pumpRatio = 2;
vid = boot();

saveDir = fullfile('C:\Users\wuyua\Desktop\Simstack\Data\', num2str(expId),  num2str(rpm), num2str(totalFlow), num2str(pumpRatio));
mkdir(saveDir);
fullName = fullfile(saveDir, 'data');

previousVw = vid.DiskLogger;
if ~isempty(previousVw)
   close(previousVw); 
end
vw = VideoWriter(fullName, 'Grayscale AVI');

vid.LoggingMode = 'disk&memory';
vid.DiskLogger = vw;
open(vw);
