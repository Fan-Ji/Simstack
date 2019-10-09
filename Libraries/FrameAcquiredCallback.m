function FrameAcquiredCallback(obj, e)
userdata = obj.UserData;
RESOLUTION = userdata.RESOLUTION;
block = userdata.block;
if (obj.FramesAvailable > 0)
    data = getdata(obj, 1);
    % imshow(data);
    block.Dwork(3).Data = reshape(data, [1, prod(RESOLUTION)]);
else
    disp('No data for frame callback, skip');
end
%flushdata(obj,'triggers');
%trigger(obj);
end

