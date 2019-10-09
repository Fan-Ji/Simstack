% ExpID = 1; % This number should be changed when material is added;
% 
% RPM = [100 200 300 400 500 600]; % After change, manual confirmation is required;
% 
% TotalFlow = [0.1 0.25 0.5 1 1.5 2]; % ml/s
% 
% PumpRatio = [0 0.2 0.4 0.6 0.8 1];

ExpID = '9'; % This number should be changed when material is added;

RPM = [400 500 600]; % After change, manual confirmation is required;

% TotalFlow = [0.1 0.25 0.5 1 1.5 2]; % ml/s
% 
% PumpRatio = [0 0.2 0.4 0.6 0.8 1];

PumpSpeeds = { ...
    {0, [0.25, 0.5, 1]}, ...% { pump1speed, [pump2speedlist]} ml/s
    {1, [0,0.25,0.5,1]}, ...
    {1.5, [0,0.25,0.5,1]}, ...
    {2, [0,0.25,0.5,1]}, ...
    }; 

Repeat = 1;

aeprm_BubblePurgeTime = 10;
aeprm_PreparationWaitTime = 10;
aeprm_ExperimentTime = 60;
aeprm_CleanCellTime = 5;
aeprm_GrayValueSetPoint = 210;

for rpm_index = 1 : numel(RPM)
   rpm_selected = RPM(rpm_index);
   cprintf('Strings', ['****** Set RPM to ' num2str(rpm_selected) ' and enter. ******\n']);
   pause;
   
   for pump1_index = 1 : numel(PumpSpeeds)
       pump1Flow = PumpSpeeds{pump1_index}{1};
       pump2Flows = PumpSpeeds{pump1_index}{2};

       for pump2_index = 1 : numel(pump2Flows)
          pump2Flow = pump2Flows(pump2_index);

          aeprm_Pump1Speed = pump1Flow;
          aeprm_Pump2Speed = pump2Flow;
          cprintf('Strings', '------ Pump1: %f; Pump2: %f \n', aeprm_Pump1Speed, aeprm_Pump2Speed);

          for repeat = 1 : Repeat
              cprintf('Strings', '--------- Repeat: %d\n', repeat)
              vid = boot();
              saveDir = fullfile('C:\Users\wuyua\Desktop\Simstack\Data\', ...
                  ExpID,  ...
                  num2str(rpm_selected), ...
                  num2str(pump1Flow), ...
                  num2str(pump2Flow), ...
                  num2str(repeat));

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

              open_system('AutoExpVideo');
              out = sim('AutoExpVideo');

              close(vw);
              delete(vw);
              vid.DiskLogger = [];
              save(fullfile(saveDir,'metadata.mat'), 'out');

          end
          
          
       end
   end
end
cprintf('Strings', ['Experiment #' num2str(ExpID) ' done\n'])
