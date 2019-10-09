sp = serial('COM10', 'BaudRate', 9600);
sp.ReadAsyncMode='manual';
sp.BytesAvailableFcnMode = 'terminator';
sp.Terminator = 'LF';
sp.BytesAvailableFcn = @(s,e)disp(fscanf(sp, '%s', sp.BytesAvailable));

fopen(sp);

fprintf(sp, 's_power 1\n');
fprintf(sp, 'arm_trigger\n');

fclose(sp);