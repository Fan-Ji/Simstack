function updateVideoWriter(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.

%   Copyright 2003-2018 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
global VIDEO_WRITER_OBJECT

setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C MEX counterpart: mdlInitializeSizes
%%
function setup(block)

% Override input port properties
% Inport 1: Video frames
block.NumInputPorts  = 4;
block.NumOutputPorts = 0;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties

id = 1; % Exp ID
block.InputPort(id).Dimensions        = 1;
block.InputPort(id).DatatypeID  = 0;  % double
block.InputPort(id).Complexity  = 'Real';

id = 2; % Total Flow
block.InputPort(id).Dimensions        = 1;
block.InputPort(id).DatatypeID  = 0;  % double
block.InputPort(id).Complexity  = 'Real';

id = 3; % Ratio
block.InputPort(id).Dimensions        = 1;
block.InputPort(id).DatatypeID  = 0;  % double
block.InputPort(id).Complexity  = 'Real';

id = 4; % RPM
block.InputPort(id).Dimensions        = 1;
block.InputPort(id).DatatypeID  = 0;  % ratio
block.InputPort(id).Complexity  = 'Real';


% Register parameters
block.NumDialogPrms     = 1; % base path

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

end%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C MEX counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 0;

end

function InitializeConditions(block)
end

%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C MEX counterpart: mdlStart
%%
function Start(block)

userdata = {};

userdata.block = block;
userdata.rpm = 0;
userdata.pumpRatio = 0;
userdata.totalFlow = 0;
userdata.experimentalID = 0;
userdata.basePath = block.DialogPrm(1).Data;
mkdir(userdata.basePath);
set(block.BlockHandle, 'UserData', userdata);

end%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C MEX counterpart: mdlOutputs
%%
function Outputs(block)


end%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C MEX counterpart: mdlUpdate
%%
function Update(block)
experimentalID = block.InputPort(1).Data;
totalFlow = block.InputPort(2).Data;
pumpRatio = block.InputPort(3).Data;
rpm = block.InputPort(4).Data;
userdata = get(block.BlockHandle,'UserData');
updateVideoWriter = 0;
if isempty(userdata.writer)
    updateVideoWriter = 1; % first run; initialize.
end
if experimentalID ~= userdata.experimentalID
    userdata.experimentalID = experimentalID;
    updateVideoWriter = 1;
end
if totalFlow ~= userdata.totalFlow
    userdata.totalFlow = totalFlow;
    updateVideoWriter = 1;
end
if rpm ~= userdata.rpm
    userdata.rpm = rpm;
    updateVideoWriter = 1;
end
if pumpRatio ~= userdata.pumpRatio
    userdata.pumpRatio = pumpRatio;
    updateVideoWriter = 1;
end

if updateVideoWriter == 1
    saveDir = fullfile(userdata.basePath, num2str(experimentalID),  num2str(rpm), num2str(totalFlow), num2str(pumpRatio));
    mkdir(saveDir);
    fullName = fullfile(saveDir, 'data');
    if ~isempty(userdata.writer)
        close(userdata.writer);
    end
    
    VIDEO_WRITER_OBJECT = VideoWriter(fullName, 'Archival');
    open(vw)
    set(block.BlockHandle, 'UserData', userdata);
    disp(['Update video writer. New file: ' fullName]);
end

end%end Update

function Derivatives(block)
end

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)
try
    close(VIDEO_WRITER_OBJECT);
catch
end
end%end Terminate
end

