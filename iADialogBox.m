function promptAns = iAParametersDB
prompt = {'Cell Type = ', 'Sensor', 'Surgeon', 'Param Name = ', 'Interleave Epoch # = ', 'Recordings = '}
dlgtitle = 'Imaging Analysis v. 1.0'; % change this when new params are added
boxDims = [1 50; 1 50; 1 50; 1 50; 1 50; 1 50];
presetInput = {'LC14', 'GC7b', 'Allison', 'sweepingFullBars_4D_5reps', '13', '[1:30]'}; % LC14: [1,3:4,6:15,17] LC14b [1:12,14:17,18...]
promptAns = inputdlg(prompt,dlgtitle,boxDims, presetInput);
% promptAns = cellfun(@strdouble,promptAns);
end