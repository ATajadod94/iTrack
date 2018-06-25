function [shortedReport keepcount] = epochFilter_iTrackReport(iTrackReport,timewin,eyeEvent)
% iTrackReport: output table from report function of iTrack
% toolbox (fix = report(z,'fixations','rois',{'eye','nose','mouth','imag'});
% interestTimeWin: a two colomn vector with first colomn being
% starting time and send ending time; if it is 3d matrix, the
% third dimention is subject
% eyeEvent: 'saccade','fixation','blink','pupil'



[a ia ic]=unique(iTrackReport.ID);
numsubs=length(a);

for s=1:numsubs
    
    data=  iTrackReport(iTrackReport.ID==a(s),:);
    interestTimeWin = timewin{s}; % here should be done better: need to check the correspondence
    switch lower(eyeEvent)
        case {'fix';'fixation';'fixations'};
        
        tstart = iTrackReport.fix_start;
        tend = iTrackReport.fix_end;
        case {'saccade';'sacc'};
        
        tstart = iTrackReport.sacc_start;
        tend = iTrackReport.sacc_end;
        case {'blink';'blinks'};
        
        tstart = iTrackReport.blink_start;
        tend = iTrackReport.blink_end;
    end
    
    [mm im in]=unique(data.eye_idx);
    for j = 1: length(mm)
   temp1= (tend(data.eye_idx ==(mm(j)))-interestTimeWin(mm(j),1)) > 20;
   
    temp2 = tstart(data.eye_idx ==(mm(j))) - interestTimeWin(mm(j),2) < -20;
    idkeep{j} = temp1.*temp2;
    keepcount(j,1)=sum(idkeep{j});
    end
    data1{s} = data(logical(cat(1,idkeep{:})),:);
        
end
shortedReport = cat(1,data1{s});


