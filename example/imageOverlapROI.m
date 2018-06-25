close all,

for i = 1:6
f{i} = dir(['C:\Users\Zhongxu\Documents\myStudy\Faces_Repetiion_fMRI\EyeTrackingData_EDF_files\Deployed_fMRI\Faces_block',num2str(i),'_fMRI_10cb\library\interestAreaSet\*.ias']);
temp = struct2cell(f{i});
fnames{i}=temp(1,:)';
end
fnamesAll=cat(1,fnames{:});
[allROINames b ]=unique(fnamesAll);


imDir='C:\Users\Zhongxu\Documents\myStudy\Faces_Repetiion_fMRI\Programming_ExptBuilder\Faces_block1_fMRI_10cb\library\images\';
a=imread([imDir,'F101.jpg']);
ima=ones(768,1024,3)*.5;
x = 768/2,y=1024/2
ima(x-240:x+240-1,y-240:y+240-1,:) = double(a)/255;
imshow(ima)
hold on;
% rectangle('position',[512-50,384-25,100,50],'LineWidth',3)
xx=(F1.x1 + F1.x2)/2;
yy=(F1.y1 + F1.y2)/2;
deltx=F1.x2-F1.x1;
delty=F1.y2-F1.y1;
for i = 1:6
rectangle('position',[F1.x1(i),F1.y1(i),deltx(i),delty(i)],'LineWidth',3);
end
roiDefDir = 'C:\Users\Zhongxu\Documents\myStudy\Faces_Repetiion_fMRI\EyeTrackingData_EDF_files\Deployed_fMRI\Faces_block1_fMRI_10cb\library\interestAreaSet\';



for nroi = 1:length(allROINames)
    rectROI = readEBRoiFiles([roiDefDir,allROINames{nroi}]);
    stimLoc = [272,144,751,623];
    if sum(table2array(rectROI(1,3:6)) == stimLoc)==4
        disp('stim loc consistent')
    else
        disp('stim loc is NOT consistent')
    end
    scnSize = [768, 1024];
    
    recROIs={'e','n','m'};
    for i = 1:3
        temp = ones(scnSize(1),scnSize(2));
        numline = strcmp(lower(rectROI.roiName),recROIs{i});
        coord = table2array(rectROI(numline,3:6));
        temp((1:scnSize(1)< (coord(2))| 1:scnSize(1)> (coord(4))), :)=0;
        temp(:, 1:scnSize(2)< coord(1)| 1:scnSize(2)> coord(3))=0;
        imshow(temp)
        hold on;
        rectangle('position',[rectROI.x1(numline),rectROI.y1(numline),...
            rectROI.x2(numline)-rectROI.x1(numline),...
            rectROI.y2(numline)-rectROI.y1(numline)],'LineWidth',3,...
            'EdgeColor','b');
        pause(.2)
    end
end
numline =1;
temp = ones(scnSize(1),scnSize(2));
coord = table2array(rectROI(numline,3:6)); 
temp((1:scnSize(1)< (coord(2))| 1:scnSize(1)> (coord(4))), :)=0;
temp(:, 1:scnSize(2)< coord(1)| 1:scnSize(2)> coord(3))=0;
hold on;
rectangle('position',[rectROI.x1(numline),rectROI.y1(numline),...
    rectROI.x2(numline)-rectROI.x1(numline),...
    rectROI.y2(numline)-rectROI.y1(numline)],'LineWidth',3,...
    'EdgeColor','b');
imshow(temp);
tempc = ones(scnSize(1),scnSize(2))-temp;
imshow(tempc);






imp=impoly
x=getPosition(imp);
aaa=roipoly(768,1024,(x(:,1)),(x(:,2)));
imshow(aaa)