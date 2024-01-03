% List all open figures
openFigs = findall(0, 'type', 'figure');
numFigs = length(openFigs);

% Specify the directory where you want to save the PDF file
saveDirectory = 'G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\PDFs'; % Change this to your desired directory

% Specify the name of the PDF file to save
pdfFileName = 'output.pdf';

% Create the full path for the PDF file
pdfFilePath = fullfile(saveDirectory, pdfFileName);

% Loop through each open figure and save it as a PDF
for i = 1:numFigs
    % Bring the figure to the front
    figure(openFigs(i));
    
    % Save the figure as a PDF file
    saveas(openFigs(i), fullfile(pdfFilePath), 'pdf');
end

% Inform the user that the export is complete
disp(['Exported ', num2str(numFigs), ' figures to ', pdfFilePath]);