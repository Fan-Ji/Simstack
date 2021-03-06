function vid = boot()
    % Device Properties.
    adaptorName = 'gentl';
    deviceID = 1;
    vidFormat = 'Mono8';
    tag = '';

    % Search for existing video input objects.
    existingObjs1 = imaqfind('DeviceID', deviceID, 'VideoFormat', vidFormat, 'Tag', tag);

    if isempty(existingObjs1)
        % If there are no existing video input objects, construct the object.
        vidObj1 = videoinput(adaptorName, deviceID, vidFormat);
    else
        % There are existing video input objects in memory that have the same
        % DeviceID, VideoFormat, and Tag property values as the object we are
        % recreating. If any of those objects contains the same AdaptorName
        % value as the object being recreated, then we will reuse the object.
        % If more than one existing video input object contains that
        % AdaptorName value, then the first object found will be reused. If
        % there are no existing objects with the AdaptorName value, then the
        % video input object will be created.

        % Query through each existing object and check that their adaptor name
        % matches the adaptor name of the object being recreated.
        for i = 1:length(existingObjs1)
            % Get the object's device information.
            objhwinfo = imaqhwinfo(existingObjs1{i});
            % Compare the object's AdaptorName value with the AdaptorName value
            % being recreated.
            if strcmp(objhwinfo.AdaptorName, adaptorName)
                % The existing object has the same AdaptorName value as the
                % object being recreated. So reuse the object.
                vidObj1 = existingObjs1{i};
                % There is no need to check the rest of existing objects.
                % Break out of FOR loop.
                break;
            elseif(i == length(existingObjs1))
                % We have queried through all existing objects and no
                % AdaptorName values matches the AdaptorName value of the
                % object being recreated. So the object must be created.
                vidObj1 = videoinput(adaptorName, deviceID, vidFormat);
            end %if
        end %for
    end %if

    % Configure vidObj1 properties.
    % Configure vidObj1's video source properties.
    srcObj1 = get(vidObj1, 'Source');
    srcObj1.ExposureTime = 45;
    srcObj1.LineSelector = 'Line1';
    srcObj1.LineMode = 'Output';
    srcObj1.LineInverter = 'true';
    srcObj1.LineSource = 'ExposureActive';
    
    vid = vidObj1;
end