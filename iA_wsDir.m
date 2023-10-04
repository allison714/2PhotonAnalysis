function promptAns = iA_wsDir
    prompt = {'Which workspace directory would you like to load?'};
    dlgtitle = 'Workspace Directory'; 
    boxDims = [1 50];
    stimDDopts = {'ManualROI', 'NoThreshold', 'Standard','P5'};
    stimIndex = listdlg('PromptString', 'Selection Criteria:', 'SelectionMode', 'single', 'ListString', stimDDopts);
    presetInput{1} = stimDDopts{stimIndex};
    promptAns = inputdlg(prompt,dlgtitle,boxDims,presetInput);
end