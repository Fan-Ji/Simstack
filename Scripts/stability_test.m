% shutting down all cameras
delete(imaqfind);

% probe new camera
gentl = imaqhwinfo('gentl');
disp(gentl.DeviceInfo);

% Open device
vid = videoinput('gentl', gentl.DeviceIDs{1});

% configuration
vid.FramesAcquiredFcnCount=0;
vid.FramesAcquiredFcn = @FramesAcquiredFcn;
vid.Timeout = Inf;
vid.FramesPerTrigger = Inf;

srcObj1 = get(vid, 'Source');
srcObj1.ExposureTime = 45;
srcObj1.LineSelector = 'Line1';
srcObj1.LineMode = 'Output';
srcObj1.LineInverter = 'true';
srcObj1.LineSource = 'ExposureActive';

% start long term capturing
start(vid);
disp('Start capturing...');
function FramesAcquiredFcn(obj,e)
    imshow(getdata(obj,1));
    fprintf('Received frame=%d\n',obj.FramesAcquired);
end