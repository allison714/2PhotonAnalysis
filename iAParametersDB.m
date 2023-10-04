function promptAns = iAParametersDB
    prompt = {'Cell Type = ', 'Sensor', 'Surgeon', 'Param Name = ', 'Recordings = ', 'Manual ROI Selection? (true/ false) '};
    dlgtitle = 'Imaging Analysis Input Parameters'; % change this when new params are added
    boxDims = [1 50; 1 50; 1 50; 1 50; 1 50; 1 50];
    presetInput = {'LC23male', 'GC7b', 'Allison', '', '[1:50]', 'false'};
    
    stimDDopts = {'sweepingFullBars_4D_5reps','vsweep_02','vsweep15_480','WaveFlashBarObjectLoom_x20y-20_3rep'};
    stimIndex = listdlg('PromptString', 'Select Param Name:', 'SelectionMode', 'single', 'ListString', stimDDopts);
    presetInput{4} = stimDDopts{stimIndex};
    promptAns = inputdlg(prompt,dlgtitle,boxDims, presetInput);
end