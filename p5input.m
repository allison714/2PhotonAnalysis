function promptAns = P5input
    prompt = {'Cell Type = ', 'Sensor', 'Surgeon', 'Param Name = ', 'Recordings = '};
    dlgtitle = 'Imaging Analysis Input Parameters'; % change this when new params are added
    boxDims = [1 50; 1 50; 1 50; 1 50; 1 50];
    
    presetInput = {'LC14', 'GC7b', 'Allison', '', '[13:15, 17:33, 35:40]'};
    
    stimDDopts = {'AllisonContrastBars01', 'Bars_Abrupt_001', 'Bars_AC_03', 'sweepingFullBars_4D_5reps', 'TargetSweep_singleNeuronRFMap_5degreso_40degArea_nogrid_10degTarg', 'vsweep_02','vsweep15_480','WaveFlashBarObjectLoom_x20y-20_3rep'};
    stimIndex = listdlg('PromptString', 'Select Param Name:', 'SelectionMode', 'single', 'ListString', stimDDopts);
    presetInput{4} = stimDDopts{stimIndex};
    promptAns = inputdlg(prompt,dlgtitle,boxDims, presetInput);
end
