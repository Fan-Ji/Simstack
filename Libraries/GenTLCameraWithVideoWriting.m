function GenTLCamera(block)
RESOLUTION = [600 800];
SAMPLING_TIME = 0.1;
setup(block);
  
%endfunction

% Function: setup ===================================================
% Abstract:
%   Set up the S-function block's basic characteristics such as:
%   - Input ports
%   - Output ports
%   - Dialog parameters
%   - Options
% 
%   Required         : Yes
%   C-Mex counterpart: mdlInitializeSizes
%
function setup(block)
  % Register the number of ports.
  % Inport 1: Gain
  block.NumInputPorts  = 1;
  
  % Output 1: Image
  % Output 2: Temperature
  % Output 3: Frame Count
  block.NumOutputPorts = 4;
  

  % Override the input port properties.
  id = 1;
  block.InputPort(id).DatatypeID  = 0;  % double
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  % Override the output port properties.
  id = 1;
  block.OutputPort(id).DatatypeID  = 3; % uint8
  block.OutputPort(id).Complexity  = 'Real';
  block.OutputPort(id).SamplingMode = 'Sample';
  block.OutputPort(id).Dimensions=RESOLUTION;
  id = 2;
  block.OutputPort(id).DatatypeID  = 0; % double
  block.OutputPort(id).Complexity  = 'Real';
  block.OutputPort(id).SamplingMode = 'Sample';
  block.OutputPort(id).Dimensions = 1;
  id = 3;
  block.OutputPort(id).DatatypeID  = 0; % double
  block.OutputPort(id).Complexity  = 'Real';
  block.OutputPort(id).SamplingMode = 'Sample';
  block.OutputPort(id).Dimensions = 1;
  id = 4;
  block.OutputPort(id).DatatypeID  = 0; % double
  block.OutputPort(id).Complexity  = 'Real';
  block.OutputPort(id).SamplingMode = 'Sample';
  block.OutputPort(id).Dimensions = 1;
  % Register the parameters.
  block.NumDialogPrms     = 0;
  block.DialogPrmsTunable = {};
  
  % Set up the continuous states.
  block.NumContStates = 0;

  % Register the sample times.
  %  [0 offset]            : Continuous sample time
  %  [positive_num offset] : Discrete sample time
  %
  %  [-1, 0]               : Inherited sample time
  %  [-2, 0]               : Variable sample time
  block.SampleTimes = [SAMPLING_TIME 0];
  
  
  % Specify the block simStateCompliance. The allowed values are:
  %    'UnknownSimState', < The default setting; warn and assume DefaultSimState
  %    'DefaultSimState', < Same SimState as a built-in block
  %    'HasNoSimState',   < No SimState
  %    'CustomSimState',  < Has GetSimState and SetSimState methods
  %    'DisallowSimState' < Errors out when saving or restoring the SimState
  block.SimStateCompliance = 'DefaultSimState';
  
  % -----------------------------------------------------------------
  % The MATLAB S-function uses an internal registry for all
  % block methods. You should register all relevant methods
  % (optional and required) as illustrated below. You may choose
  % any suitable name for the methods and implement these methods
  % as local functions within the same file.
  % -----------------------------------------------------------------
   
  % -----------------------------------------------------------------
  % Register the methods called during update diagram/compilation.
  % -----------------------------------------------------------------
  
  % 
  % CheckParameters:
  %   Functionality    : Called in order to allow validation of the
  %                      block dialog parameters. You are 
  %                      responsible for calling this method
  %                      explicitly at the start of the setup method.
  %   C-Mex counterpart: mdlCheckParameters
  %
  block.RegBlockMethod('CheckParameters', @CheckPrms);
  
  
  %
  % PostPropagationSetup:
  %   Functionality    : Set up the work areas and the state variables. You can
  %                      also register run-time methods here.
  %   C-Mex counterpart: mdlSetWorkWidths
  %
  block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);

  % -----------------------------------------------------------------
  % Register methods called at run-time
  % -----------------------------------------------------------------
  
  % 
  % ProcessParameters:
  %   Functionality    : Call to allow an update of run-time parameters.
  %   C-Mex counterpart: mdlProcessParameters
  %  
  block.RegBlockMethod('ProcessParameters', @ProcessPrms);

  % 
  % InitializeConditions:
  %   Functionality    : Call to initialize the state and the work
  %                      area values.
  %   C-Mex counterpart: mdlInitializeConditions
  % 
  block.RegBlockMethod('InitializeConditions', @InitializeConditions);
  
  % 
  % Start:
  %   Functionality    : Call to initialize the state and the work
  %                      area values.
  %   C-Mex counterpart: mdlStart
  %
  block.RegBlockMethod('Start', @Start);

  % 
  % Outputs:
  %   Functionality    : Call to generate the block outputs during a
  %                      simulation step.
  %   C-Mex counterpart: mdlOutputs
  %
  block.RegBlockMethod('Outputs', @Outputs);

  % 
  % Update:
  %   Functionality    : Call to update the discrete states
  %                      during a simulation step.
  %   C-Mex counterpart: mdlUpdate
  %
  block.RegBlockMethod('Update', @Update);
  
  % 
  % SimStatusChange:
  %   Functionality    : Call when simulation enters pause mode
  %                      or leaves pause mode.
  %   C-Mex counterpart: mdlSimStatusChange
  %
  block.RegBlockMethod('SimStatusChange', @SimStatusChange);
  
  % 
  % Terminate:
  %   Functionality    : Call at the end of a simulation for cleanup.
  %   C-Mex counterpart: mdlTerminate
  %
  block.RegBlockMethod('Terminate', @Terminate);
  
  block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
end %endfunction

% -------------------------------------------------------------------
% The local functions below are provided to illustrate how you may implement
% the various block methods listed above.
% -------------------------------------------------------------------

function CheckPrms(block)
  
end %endfunction

function ProcessPrms(block)

  block.AutoUpdateRuntimePrms;
 
end %endfunction

function SetInputPortSamplingMode(block, idx, fd)
    block.InputPort(idx).SamplingMode = fd;
end


function DoPostPropSetup(block)
  % D1: Gain
  % D2: Temperature
  % D3: Image
  block.NumDworks = 3; 
  
  block.Dwork(1).Name            = 'Gain';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = false;
  
  block.Dwork(2).Name            = 'Temperature';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = false;
  
  block.Dwork(3).Name = 'Image';
  block.Dwork(3).Dimensions      = prod(RESOLUTION);
  block.Dwork(3).DatatypeID      = 3;      % uint8
  block.Dwork(3).Complexity      = 'Real'; % real
  block.Dwork(3).UsedAsDiscState = false;
  
  % Register all tunable parameters as runtime parameters.
  block.AutoRegRuntimePrms;

end %endfunction

function InitializeConditions(block)
end %endfunction

function Start(block)
  block.Dwork(1).Data = 0;
  block.Dwork(2).Data = 0; 
  % block.Dwork(3).Data = zeros(prod(RESOLUTION),1);
  % Configure camera
  %vid = boot(); % assume bootstrap has been run by user
  vid = evalin('base', 'vid');
  %triggerconfig(vid, 'manual');
  src = get(vid, 'Source');
  disp('Successfully started camera');
  vid.FramesAcquiredFcnCount=1;
  vid.FramesAcquiredFcn = @FrameAcquiredCallback;
  vid.Timeout = 0;
  vid.ErrorFcn = @ErrorFcnCallback;
  vid.FramesPerTrigger = Inf;
  vid.TriggerRepeat=Inf;

  
  src.AcquisitionFrameRateMode = 'Basic';
  src.AcquisitionFrameRate = 1/SAMPLING_TIME;
  
  
  tm = timer;
  tm.Name = 'TemperatureReadingTimer';
  tm.ExecutionMode = 'fixedSpacing';
  tm.Period = 1;
  tm.TimerFcn = @TemperatureTimerFcn;
  
  
  userdata = {};
  userdata.vid = vid;
  userdata.tm = tm;
  userdata.src = src;
  userdata.RESOLUTION = RESOLUTION;
  userdata.block = block;
  
  tm.UserData = userdata;
  set(block.BlockHandle, 'UserData', userdata);
  vid.UserData = userdata;
  
  start(tm);
  start(vid);
  %trigger(vid);
  disp(vid);
end %endfunction

function Outputs(block)
  userdata = get(block.BlockHandle,'UserData');
  vid = userdata.vid;
  block.OutputPort(2).Data = block.Dwork(2).Data;
  
  block.OutputPort(1).Data = reshape(block.Dwork(3).Data, RESOLUTION);
  
  block.OutputPort(3).Data = vid.FramesAcquired;
  block.OutputPort(4).Data = vid.DiskLoggerFrameCount;
end %endfunction

function Update(block)
  if block.Dwork(1).Data ~= block.InputPort(1).Data
      block.Dwork(1).Data = block.InputPort(1).Data;
      userdata = get(block.BlockHandle,'UserData');
      src = userdata.src;
      src.Gain = block.Dwork(1).Data;
      fprintf('Gain updated: %f', block.Dwork(1).Data);
  end
end %endfunction


function SimStatusChange(block, s)
  
end %endfunction
    
function Terminate(block)

disp(['Terminating the block with handle ' num2str(block.BlockHandle) '.']);
userdata = get(block.BlockHandle,'UserData');
stop(userdata.tm);
stop(userdata.vid);
end %endfunction

end