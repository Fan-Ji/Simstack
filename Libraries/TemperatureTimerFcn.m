function TemperatureTimerFcn(obj, e)
  userdata = obj.UserData;
  src = userdata.src;
  userdata.block.Dwork(2).Data = src.DeviceTemperature;
end

