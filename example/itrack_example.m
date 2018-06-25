%% clear workspace and setup directories

clear
clc
close all;

%first cd to wherever you put the iTrack folder (e.g., ~/Downloads/iTrack)
datadir='C:\Users\Zhongxu\Documents\MATLAB\myMatLabTools\iTrack-masterNew\example';
cd(datadir)

%get the name of all edf files in the directory
edffiles = dir('*.edf');
edffiles = {edffiles(1).name}

%% Load EDFs

%trials in edf file that don't exist in behavioral file. You don't have to remove, but you can 
extra_trials = [
    1
    102
    183
    264
    345
    426
    507
    588
    669
    750
    831]

clear z

%iTrack(edffiles) will import all trials, without samples. This is what you
%want for most situations. 

%this shows all the available options
z = iTrack(edffiles,'subject_var','ID','samples',true,'droptrials',extra_trials,'keeptrials',[],'keepraw',false); %if you're only looking at fixations, change 'samples' to false!
% z = iTrack(edffiles,'subject_var','ID','samples',true,'keeptrials',[],'keepraw',false); %if you're only looking at fixations, change 'samples' to false!

%1024 x 768 is the default screen resolution. You can change it this way. 
% z.screen.dims = [1024, 768]; 


methods(z) %lists all functions associated with the object

%% if you say "keepraw"

% z = reset(z); %go back to the original data without reloading edfs; 


%% Merge with Behavioral Data

load beh.mat; %adds the table, 'beh' to the workspace

%%

%ideally, you send some message to Eyelink on each trial to identify it. In
%this case, each trial has 'TRIAL XX' and 'BLOCK XX'. These are used as
%indexes for merging. If you don't have such an index, then if your behavioral
%file has the same # of trials as your edf file, it will still merge.

%this creates 2 new fields, based on the messages sent to eyelink, giving
%them the names 'Block' and 'Trial' to match the behavioral data.
%'striptext' removes everything but the numbers from each one
z= add_fields(z,'events',true,'search',{'BLOCK *', 'TRIAL '},'fieldnames',{'Block','Trial'},'striptext',true);

%%
%you can create new events manually if you forgot to record them:
% z = add_event(z,'NEW_EVENT',1500);

%merge our behavioral data with the eytracking
%you can specify a table or dataset in the workspace, or a text file that
%can be loaded as a table (e.g., 'exp1beh.txt')
z = add_behdata(z,beh,'index',{'Block','Trial'},'append',false); %'append' allows you to add more variables later

%this pulls out the timing of an eyetracking event and adds a field to the
%behavioral portion
z = extract_event(z,'search','STIMONSET','time',true,'behfield',true);
z = extract_event(z,'search','RESPONSE','time',true,'behfield',true);

%%

%%%%%%%%%% FIXATION-BASED WORKFLOW %%%%%%%%%%%%%%%%%%%%%


%% make ROIs for fixation analysis

z = clearROIs(z);


coords = radialCoords(512,384,12,200,0); %creates coordinates of 12 objects, centered at [512,384] with a radius of 200 and starting at 0 degrees


coords = horzcat(randsample(1024,2000,1),randsample(768,2000,1));
for i = 1:2000
    roinames{i}=['face',sprintf('%04d',i)];
end
z = makeROIs(z,coords,'shape','circle','xradius',40,'names',roinames); %elliptical rois rotated


% z = makeROIs(z,coords,'shape','circle','radius',75); %simple circular rois
z = makeROIs(z,coords,'shape','ellipse','xradius',40,'yradius',150,'angle',0:30:360); %elliptical rois rotated


z = combineROIs(z); %make one composite ROI- useful for visualization 

displayROIs(z); %vizualize the ROIs and label them

%%


%quickly view scatterplots of all subjects with overlays for ROIs 
quickview(z)

%%

%OPTIONAL - perform drift correction for each block and subject.
%This calculates the median of the x and y coordinates for each block, and
%treats that as the "true" center, and adjusts all fixations by this offset
%from the screen center (z.screen.dims)

z = drift_correct(z,{'Block'},'plot',true);

%% Calculate "hits" for each ROI

%calculate whether the eyes hit a given roi (fixations and saccades)
tic
z = calcHits(z,'rois','all');
toc
for i = 1:860
    a=randsample(5,1);
roiall{i}=roinames(randsample(2000,a));
end
 z = calcHits_zx(z,'rois',roiall);

%%

%using behavioral variables to indicate trial-by-trial ROIs
z = mapROIs(z,'name',{'target','distractor'},'indicator',{'Targetpos','Distpos'});

%%z = calcHits(z,'rois','1');
%%

%this creates a timeseries indicating whether eyes hit a given roi across
%time
z = calcHitsOverTime(z,'rois',{'target','distractor'});

%% Epoch

%first index the events so we can line up the trials (only need to do once)
z=index_events(z,{'STIMONSET','RESPONSE'});

%epoch by giving the interval for each event [ms_before, ms_after]
%the same function also handles pupil data, hence the 'type' argument
z=epoch(z,'event','STIMONSET','interval',[0,750],'type','fix','rois',{'target','distractor'}); %'type' can also be baselined (pupil data) or 'raw' (also pupil data)
z=epoch(z,'event','RESPONSE','interval',[750,0],'type','fix','rois',{'target','distractor'});

%% bin our epoched data in 25ms intervals (optional)

z = binData(z,25,'events',{'STIMONSET','RESPONSE'},'fix',true,'rois',{'target','distractor'});

%% Scatterplots

%creates a separate figure for each level of 'Switch' and 'Targetpos', and
%a separate subplot for fixations that hit the target or not (optional)
close all
scatterplots(z,{'Switch','Targetpos'},'roi',{'target'},'overlay',true,'hitonly',true)

scatterplots(z,{'Switch','Distpos'},'roi',{'distractor'},'overlay',true,'hitonly',true)

%% Line Plots

%you can specify multipl plotVars and lineVars
plotVars={'CSI'}; %for making separate figures
lineVars={'Switch'}; %for plotting separate lines on the same figures
dataVar='STIMONSET'; %our data we want to plot (in this case, the event we're time locked to)
roi = 'target'; %for fixations, we need to specify an ROI

close all

allfigdata=linePlots(z,'plotVars',plotVars,'dataVar',dataVar,'legend',1,'lineVars',lineVars,'ylim',[0 1],...
    'LineWidth',2,'roi',roi,'filter','GoodTrial','value',1,'lineVars',lineVars); %you can use 'filter' to throw out error trials, etc.


%% Saving flat tables for further analyses

fix = report(z,'fixations','rois',{'target','distractor'}); %fixations
sac = report(z,'saccades','rois',{'target','distractor'}); %saccades
blinks = report(z,'blinks'); %blinks
counts = report(z,'counts'); %counts of the different events
fixepoch = report(z,'epoched_fixations','events',{'STIMONSET'},'rois',{'target','distractor'}); %fixations

%%

%this is a work in progress. quickly grabbing epoched fixations as
%matrices

eye_beh = get_new(z,'beh'); %behavioral data that has been merged with eye data
[stimtar,stimdist,resptar,respdist] = get_new(z,'epoched_fixations','events',{'STIMONSET','RESPONSE'},'rois',{'target','distractor'});

eyedata = eye_beh;
eyedata.target_STIMONSET = stimtar;
eyedata.target_RESPONSE = resptar;


%% Line plots from our flat table

plotVars={'CSI'}; %for making separate figures
lineVars={'Switch'}; %for plotting separate lines on the same figures
dataVar = 'target_STIMONSET';
roi='target'; %our data we want to plot (in this case, the event we're time locked to)

allfigdata=linePlots(eyedata,'plotVars',plotVars,'dataVar',dataVar,'legend',1,'lineVars',lineVars,'ylim','auto',...
    'LineWidth',2,'filter','GoodTrial','value',1,'lineVars',lineVars); %you can use 'filter' to throw out error trials, etc.


%% 
%%%%%%%%%%%%%%%%%%%%% PUPIL-BASED WORKFLOW %%%%%%%%%%%%%%%%%%%

%% First, let's look at our raw pupil data
%get is a general-purpose function for quickly grabbing data.
[rawcell,checkraw]  = get(z,'raw'); 

close all
%it's a mess if we plot everything, let's just look at 25 random trials
randrows = randsample(1:size(checkraw,1),25,0);
plot_all_rows(checkraw(randrows,2:end)); 




%% PUPIL DATA - Artifacts

%There are 3 complementary blink removal algorithms
%additionally there is a 'badxy' and a 'low_cutoff' setting that removes bad
%samples. These are on by default. There's also an 'outliers' argument for removing outliers (but doesn't typically work well)
%If you don't specify any options it removes only very obvious artifacts: 
%EL_blinks (removing blinks identified by EyeLink), low_cutoff (samples with pupil size < 100), 
%and badxy (samples where x/y coordinates are > 10,000) by default
z=remove_artifacts(z,...
    'filter_blinks',true,...
    'EL_blinks',true,...
    'sliding_window',true,...
    'interpolate',true,...
    'smooth',0,...
    'contiguous',0,...
    'contiguous_cutoff',100);

%%
%let's look at how the cleaning worked
[~,checkcleaned]  = get(z,'raw'); 


randrows = randsample(1:size(checkraw,1),25,0);
close all
plot_all_rows(checkraw(randrows,2:end)); 
plot_all_rows(checkcleaned(randrows,2:end)); 
placeFigures


%% Baseline each trial of pupil data
baseline_times = [200:300]; %this specifies ms from beginning of recording, not samples
z=baseline(z,baseline_times,'method','percent'); %can also 'subtract'




%% Epoch pupil data

z=index_events(z,{'STIMONSET','RESPONSE'}); %already did this above for fixation data

z=epoch(z,'event','STIMONSET','interval',[1500,500],'type','baselined'); %'type' can be 'fix' (fixation data), 'baselined' (default,pupil data) or 'raw' (also pupil data)
z=epoch(z,'event','RESPONSE','interval',[1200,0]);


%% Optional - bin pupil data using a running median (can also do running mean, but median works better)

z = binData(z,25,'fix',false,'events',{'STIMONSET','RESPONSE'},'func','median');
%this makes our data smaller. To go back to the original, just epoch again!

%% Line Plots of our pupil data

factors={'Switch'};
dataVar='STIMONSET';
lineVars={'CSI'};

close all

allfigdata=linePlots(z,'plotVars',factors,'dataVar',dataVar,'legend',1,'ylim','auto','fix',false,...
    'LineWidth',2,'lineVars',lineVars,'filter','GoodTrial','value',1,'func',@mean); %you can also set the 'ylim' for all figures manually 


%% Save pupil data in a flat table


%this is a work in progress. quickly grabbing epoched fixations as
%matrices

eye_beh = get_new(z,'beh'); %behavioral data that has been merged with eye data
[pupil_stim,pupil_resp] = get_new(z,'epoched_pupil','events',{'STIMONSET','RESPONSE'});

pupildata = eye_beh;
pupildata.PUPIL_STIMLOCKED = pupil_stim;
pupildata.PUPIL_RESPLOCKED = pupil_resp;


%% Line Plots of our pupil data starting from the flat table

factors={'Switch'};
dataVar='PUPIL_STIMLOCKED';
lineVars={'CSI'};


close all

allfigdata=linePlots(pupildata,'plotVars',factors,'dataVar',dataVar,'legend',1,'ylim','auto','fix',false,...
    'LineWidth',2,'lineVars',lineVars,'filter','GoodTrial','value',1,'func',@mean); %you can also set the 'ylim' for all figures manually 


