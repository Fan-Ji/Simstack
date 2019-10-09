function TwoPumpControl(block)
SERIAL_NAME = 'COM11';
BAUD_RATE = 9600;
DEV_ADDRESS_1 = 192; %c0
DEV_ADDRESS_2 = 192+8; 

SAMPLING_TIME = 0.5;
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
  % Inport 1: Pump speed 
  % Inport 2: Pump direction (int8); 1: forward; 0: stop; -1: backward;
  block.NumInputPorts  = 4;
  
  block.NumOutputPorts = 0;
  
  % Set up the port properties to be inherited or dynamic.
  block.SetPreCompInpPortInfoToDynamic;

  % Override the input port properties.
  id = 1; % Speed
  block.InputPort(id).DatatypeID  = 1;  % single
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  id = 2; % Direction and stop
  block.InputPort(id).DatatypeID  = 2;  % int8
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  id = 3; % Speed
  block.InputPort(id).DatatypeID  = 1;  % single
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  id = 4; % Direction and stop
  block.InputPort(id).DatatypeID  = 2;  % int8
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
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
  % D1: Speed
  % D2: Dir and stop
  block.NumDworks = 4; 
  
  id = 1;
  block.Dwork(id).Name            = 'Speed_1';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 1;      % single
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 2;
  block.Dwork(id).Name            = 'Dir_Stop_1';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 2;      % int8
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 3;
  block.Dwork(id).Name            = 'Speed_2';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 1;      % single
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 4;
  block.Dwork(id).Name            = 'Dir_Stop_2';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 2;      % int8
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  % Register all tunable parameters as runtime parameters.
  block.AutoRegRuntimePrms;

end %endfunction

function InitializeConditions(block)
end %endfunction

function Start(block)
  block.Dwork(1).Data = single(0);
  block.Dwork(2).Data = int8(0); 
  block.Dwork(3).Data = single(0);
  block.Dwork(4).Data = int8(0); 
  
  sp = serial(SERIAL_NAME, 'BaudRate', BAUD_RATE);

  fopen(sp);
  fwrite(sp, rtuwritecoil(DEV_ADDRESS_2, 16, 04, 65280)); % start RS485 control
  pause(0.1);
  fwrite(sp, rtuwritecoil(DEV_ADDRESS_1, 16, 04, 65280)); % start RS485 control

  async_queue_timer = timer;
  async_queue_timer.Period = 0.3;
  async_queue_timer.ExecutionMode = 'fixedDelay';
  async_queue_timer.TimerFcn = @TimerCallback;
  
  queue = CQueue();
  userdata = {};
  userdata.timer = async_queue_timer;
  userdata.queue = queue;
  userdata.sp = sp;
  userdata.block = block;
  async_queue_timer.UserData = userdata;
  
  set(block.BlockHandle, 'UserData', userdata);
end %endfunction

function Outputs(block)
end %endfunction

function Update(block)
  userdata = get(block.BlockHandle,'UserData');
  sp = userdata.sp;
  queue = userdata.queue;
  tmr = userdata.timer;
  % Pump 1
  DEV_ADDRESS = DEV_ADDRESS_1;
  ind = 1;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Pump speed 1 updated: %d\n', block.Dwork(ind).Data);

      buf = rtuwritereg(DEV_ADDRESS, 48, 01, 2, 4, block.Dwork(ind).Data);
      queue.push(buf);

      try
        start(tmr);
      catch
      end
  end
  ind = 2;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Pump direction 1 updated: %d\n', block.Dwork(ind).Data);
      buf = rtuwritecoil(DEV_ADDRESS, 16, 01, 0); % stop
      queue.push(buf);
      if(block.Dwork(ind).Data ~= 0)
          if block.Dwork(ind).Data > 0
            buf = rtuwritecoil(DEV_ADDRESS, 16, 03, 65280); % fwd
          else
            buf = rtuwritecoil(DEV_ADDRESS, 16, 03, 0); % bkwd
          end
          queue.push(buf);
          buf = rtuwritecoil(DEV_ADDRESS, 16, 01, 65280); % start
          queue.push(buf);
      end
      try
        start(tmr);
      catch
      end
  end
  % Pump 2
  DEV_ADDRESS = DEV_ADDRESS_2;
  ind = 3;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Pump speed 2 updated: %d\n', block.Dwork(ind).Data);
      buf = rtuwritereg(DEV_ADDRESS, 48, 01, 2, 4, block.Dwork(ind).Data);
      queue.push(buf);
      try
        start(tmr);
      catch
      end
  end
  ind = 4;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Pump direction 2 updated: %d\n', block.Dwork(ind).Data);
      buf = rtuwritecoil(DEV_ADDRESS, 16, 01, 0); % stop
      queue.push(buf);
      if(block.Dwork(ind).Data ~= 0)
          if block.Dwork(ind).Data > 0
            buf = rtuwritecoil(DEV_ADDRESS, 16, 03, 65280); % fwd
          else
            buf = rtuwritecoil(DEV_ADDRESS, 16, 03, 0); % bkwd
          end
          queue.push(buf);
          buf = rtuwritecoil(DEV_ADDRESS, 16, 01, 65280); % start
          queue.push(buf);
      end
      try
        start(tmr);
      catch
      end
  end
end %endfunction


function SimStatusChange(block, s)
  
end %endfunction
    
function Terminate(block)

disp(['Terminating the block with handle ' num2str(block.BlockHandle) '.']);
userdata = get(block.BlockHandle,'UserData');
sp = userdata.sp;
fwrite(sp, rtuwritecoil(DEV_ADDRESS_1, 16, 04, 0)); % stop RS485 control
pause(0.1);
fwrite(sp, rtuwritecoil(DEV_ADDRESS_2, 16, 04, 0)); % stop RS485 control

fclose(userdata.sp);
end %endfunction

function TimerCallback(t, e)
    userdata = t.UserData;
    queue = userdata.queue;
    sp = userdata.sp;
    if queue.isempty()
        stop(t);
    else
        fwrite(sp, queue.pop());
    end
end
end