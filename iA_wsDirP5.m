function promptAns = iA_wsDirP5
    prompt = {'Which workspace directory would you like to load?'};
    dlgtitle = 'Workspace Directory'; 
    boxDims = [1 50];
    % stimDDopts = {'ManualROI', 'NoThreshold', 'Standard','P5'};
    % stimIndex = listdlg('PromptString', 'Selection Criteria:', 'SelectionMode', 'single', 'ListString', stimDDopts);
    % presetInput{1} = stimDDopts{stimIndex};
    presetInput{1} = 'P5';
    promptAns = inputdlg(prompt,dlgtitle,boxDims,presetInput);
end