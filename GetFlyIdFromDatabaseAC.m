function flyIDnum = GetFlyIdFromDatabaseAC(dataPath)

% Commented and edited by RT 4/2/2021
% Given absolute paths to the imaging data (as provided by
% getPathsFromDatabase), return fly IDs as a uint64 vector

% Get system configuration to find where's the database/data directory
sysConfig = GetSystemConfiguration;
% I no longer consider the case where you have a local copy of database and
% looking at that (because no one is doing that)
connDb = connectToDatabase(sysConfig.databasePathServer);

flyIDnum = uint64(zeros(1,length(dataPath)));

% First, list out possible locations of the data:
localDir = sysConfig.twoPhotonDataPathLocal;
AliceDir = sysConfig.twoPhotonDataPathAliceServer;
BobDir   = sysConfig.twoPhotonDataPathBobServer;

% Unify slashes to backslash
% Note: Backslash is used as the file separator only in Windows and not in
% linux/Mac, but the database stores relative datapath using \ rather than /.
% Thus your sysConfig.csv likely has paths with / but we need to unify it to 
% \ here.

localDir(localDir=='/') = '\';
AliceDir(AliceDir=='/') = '\';
BobDir(BobDir=='/')     = '\';

% In case your direcotry paths did not end with slashes, append one
% (too much safety feature?)
if localDir(end)~='\'; localDir(end+1) = '\'; end
if AliceDir(end)~='\'; AliceDir(end+1) = '\'; end
if BobDir(end)~='\';   BobDir(end+1) = '\';   end

% Go through the (absolute) data paths one by one
for i = 1:length(dataPath)
    moviePathIn = dataPath{i};
    % Unify to back slashes
    moviePathIn(moviePathIn == '/') = '\';
    % Remove data directory paths from absolute data paths
    if contains(moviePathIn, localDir)
        relativeDataPath = moviePathIn(length(localDir)+1:end-1);
    elseif contains(moviePathIn, AliceDir)
        relativeDataPath = moviePathIn(length(AliceDir)+1:end-1);
    elseif contains(moviePathIn, BobDir)
        relativeDataPath = moviePathIn(length(BobDir)+1:end-1);
    else
        error(['The data path ',moviePathIn,' does not contain any of 2p data directory designated in sysConfig.csv. Check sysConfig?']);
    end
    % Probe the database
    flyIdCell = fetch(connDb, sprintf('select flyId from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%%%s%%"', relativeDataPath));
    
    if istable(flyIdCell) % for newer matlab version
        flyIdCell = table2cell(flyIdCell);
    end
    flyIDnum(i) = flyIdCell{1};
end
close(connDb);
end