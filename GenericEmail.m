%% Send Emails from Excel File Data
% A. Cairns
% 10.02.23
% Note: Excel file should be in MatlabFile

clc; clearvars; close all;

%% I. Import Data
% % opts = detectImportOptions('GenericEmail.xlsx'); % Tool for trouble shooting
data = readtable('GenericEmail.xlsx', MissingRule='omitvar');
data = table2cell(data);
email1 = data(:,1);
name1 = data(:,2);
title1 = data(:,3);
email2 = data(:,4);
name2 = data(:,5);
title2 = data(:,6);

%% II. Compose Email
% sendmail({'recipient@someserver.com','recipient2@someserver.com'}, 'Hello From MATLAB!');
for i = 1: length(email1)
    message = ['Hello ', cellstr(name1(i)), ' who is a ', cellstr(title1(i)), ' and ', cellstr(name2(i)), ' who is a ', cellstr(title2(i)), '. You two have been paired as a match for the WISAY Mentorship Program!'];
    sendmail({email1(i),email2(i)}, ...
        message);
end