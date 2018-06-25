for i = 1:6
datadir{i} = ['C:\Users\Zhongxu\Documents\myStudy\Faces_Repetiion_fMRI\EyeTrackingData_EDF_files\Deployed_fMRI\Faces_block',num2str(i),'_fMRI_10cb\datasets\'];

filename = [datadir{i},'Trial_DataSource_Faces_block',num2str(i),'_fMRI_10cb_BlockTrial.dat'];
delimiter = '\t';
startRow = 2;
formatSpec = '%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

roiNames{i} = dataArray{:, 1};

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

end

roiNames=cat(1,roiNames{:});
[a b]=unique(roiNames);

for i = 1:6
f{i} = dir(['C:\Users\Zhongxu\Documents\myStudy\Faces_Repetiion_fMRI\EyeTrackingData_EDF_files\Deployed_fMRI\Faces_block',num2str(i),'_fMRI_10cb\library\interestAreaSet\*.ias']);
temp = struct2cell(f{i});
fnames{i}=temp(1,:)';
end
fnamesAll=cat(1,fnames{:});
[allROINames b ]=unique(fnamesAll);
%check
for i = 1:6
   [aa]=intersect(allROINames,fnames{i}) ;
  bb{i}=aa;  
end
%ok
