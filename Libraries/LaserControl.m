function LaserControl(block)
SERIAL_NAME = 'COM10';
BAUD_RATE = 115200;
SAMPLING_TIME = 1;
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
  % Inport 1: Exposure Time
  % Inport 2: Filter
  % Inport 3: Delay
  % Inport 4: Power
  % Inport 5: Arm trigger
  block.NumInputPorts  = 5;
  
  block.NumOutputPorts = 0;
  
  % Set up the port properties to be inherited or dynamic.
  block.SetPreCompInpPortInfoToDynamic;

  % Override the input port properties.
  id = 1; % Exposure time (tick not us)
  block.InputPort(id).DatatypeID  = 7;  % uint32
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  id = 2; % Filter
  block.InputPort(id).DatatypeID  = 7;  % uint32
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  id = 3; % Delay
  block.InputPort(id).DatatypeID  = 7;  % uint32
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
  
  id = 4; % Power
  block.InputPort(id).DatatypeID  = 3;  % uint8
  block.InputPort(id).Complexity  = 'Real';
  block.InputPort(id).Dimensions = 1;
 
  id = 5; % Arm trigger
  block.InputPort(id).DatatypeID  = 8;  % boolean
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
  % D1: Exposure Time
  % D2: Filter
  % D3: Delay
  % D4: Power
  % D5: Arm trigger
  block.NumDworks = 5; 
  
  id = 1;
  block.Dwork(id).Name            = 'Exposure_Time';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 7;      % uint32
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 2;
  block.Dwork(id).Name            = 'Filter';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 7;      % uint32
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 3;
  block.Dwork(id).Name            = 'Delay';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 7;      % uint32
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 4;
  block.Dwork(id).Name            = 'Power';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 3;      % uint8
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  id = 5;
  block.Dwork(id).Name            = 'Arm_Trigger';
  block.Dwork(id).Dimensions      = 1;
  block.Dwork(id).DatatypeID      = 8;      % bool
  block.Dwork(id).Complexity      = 'Real'; % real
  block.Dwork(id).UsedAsDiscState = false;
  
  % Register all tunable parameters as runtime parameters.
  block.AutoRegRuntimePrms;

end %endfunction

function InitializeConditions(block)
end %endfunction

function Start(block)
  block.Dwork(1).Data = uint32(0);
  block.Dwork(2).Data = uint32(0); 
  block.Dwork(3).Data = uint32(0); 
  block.Dwork(4).Data = uint8(0); 
  block.Dwork(5).Data = false; 
  
  sp = serial(SERIAL_NAME, 'BaudRate', BAUD_RATE);
  sp.BytesAvailableFcnMode = 'terminator';
  sp.Terminator = 'LF';

  fopen(sp);

  userdata = {};
  userdata.sp = sp;
  userdata.block = block;
  
  set(block.BlockHandle, 'UserData', userdata);
end %endfunction

function Outputs(block)
end %endfunction

function Update(block)
  userdata = get(block.BlockHandle,'UserData');
  sp = userdata.sp;
  ind = 1;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Exposure updated: %d\n', block.Dwork(ind).Data);
      fprintf(sp, 's_exposure %d\ncommit\n', double(block.Dwork(ind).Data));
  end
  ind = 2;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Filter updated: %d\n', block.Dwork(ind).Data);
      fprintf(sp, 's_filter %d\ncommit\n', double(block.Dwork(ind).Data));
  end
  ind = 3;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Delay updated: %d\n', block.Dwork(ind).Data);
      fprintf(sp, 's_delay %d\ncommit\n', double(block.Dwork(ind).Data));
  end
  ind = 4;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Power updated: %d\n', block.Dwork(ind).Data);
      fprintf(sp, 's_power %d\n', double(block.Dwork(ind).Data));
  end
  ind = 5;
  if block.Dwork(ind).Data ~= block.InputPort(ind).Data
      block.Dwork(ind).Data = block.InputPort(ind).Data;
      fprintf('Trigger updated: %d\n', block.Dwork(ind).Data);
      if block.Dwork(ind).Data 
          fprintf(sp, 'arm_trigger\n');
      else
          fprintf(sp, 'disarm_trigger\n');
      end
  end
end %endfunction


function SimStatusChange(block, s)
  
end %endfunction
    
function Terminate(block)

disp(['Terminating the block with handle ' num2str(block.BlockHandle) '.']);
userdata = get(block.BlockHandle,'UserData');
fprintf(userdata.sp, 'disarm_trigger\n');
fclose(userdata.sp);
end %endfunction

end