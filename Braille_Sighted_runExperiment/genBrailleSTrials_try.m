
function sti = genBrailleSTrials_try(subjID,group,eyes) 
%% Load all trial information files 

   dir.data = [pwd '/brailleS_data'];
   dir.trials = [pwd '/brailleS_trials'];
   load([pwd '/brailleS_vars.mat'])  
   
   if group == 1; 
       AWlist = words1; VWlist = words2; 
   elseif group == 2; 
       AWlist = words2; VWlist = words1;  
   end  
   
   ABlist = AWlist; CSlist = csList; FFlist = csList; 
   rootNameS = ['brailleS_' subjID '_grp' num2str(group)]; 
   file.trials_csv = [rootNameS '_trials.csv']; file.trials_mat = [rootNameS '_trials.mat'];
   
   if strcmp(eyes,'open') % 1 is open, 2 is closed 
       restOrd = [1 2 2 1 2 1 2 1 1 2 1 2 1 2 2 1 2 1 2 1 1 2 1 2 1 2 2 1 2 1]; 
   elseif strcmp(eyes,'closed')
       restOrd = [2 1 1 2 1 2 1 2 2 1 2 1 2 1 1 2 1 2 1 2 2 1 2 1 2 1 1 2 1 2];
   end       
   
%% pseudo-randomizing Y/N & making sure equal # of Y/N for all conditions 

fprintf('\n Generating new trials for Subject %s, Group %d... %s \n',subjID,group,eyes)
runsCONew = [runsCondOrder(1,:)';runsCondOrder(2,:)';runsCondOrder(3,:)';...
        runsCondOrder(4,:)';runsCondOrder(5,:)'];
rawOrd = [ones(10,1); zeros(10,1)]; finalOrd = []; bad=1; bad2=1; 

while bad2 == 1 
    for i = 1:5
        while bad == 1 
            bad = 0; 
            randNew = randperm(20); 
            newOrd = rawOrd(randNew);
            for j = 1:17 
                sum4t = sum(newOrd(j:j+3)); 
                if sum4t == 4 || sum4t == 0 
                    bad = 1;
                end 
            end 
        end 
    finalOrd = vertcat(finalOrd, newOrd);
    end
    condAll = []; finalOrd2 = finalOrd;  
    for i = 1:130 
        if runsCONew(i) > 0 
            condAll = vertcat(condAll, [runsCONew(i) finalOrd2(1)]); 
            finalOrd2(1) = []; 
        else 
        condAll = vertcat(condAll, [runsCONew(i) 0]); 
        end 
    end 
    finalOrd3 = condAll(:,2); 
    bad2 = 0; 
    for i = 1:5
        found{i} = find(ismember(runsCONew,i));
        sumRun{i} = sum(finalOrd3(found{i})); 
        if sumRun{i} ~= 10 
            bad2 = 1; 
        end 
    end 
end

yesNoTrial = finalOrd3; % 1 is NO, 0 is YES trial 
finalOrd3(find(finalOrd3==0)) = 2; % 1 is YES, 2 is NO (Cedrus button) 
corrAns = finalOrd3;

% NOTE: It might look like there's four '2' in a row sometimes, but that's
% because 'rest' answers are also coded as 2... 

%% Making "final" list of stimuli

AWrand = randperm(20)
ABrand = randperm(20)
VWrand = randperm(20); CSrand = randperm(20); FFrand = randperm(20); 
stimList = []; 
noProbes = 1:20; noProbeInd = randperm(20); 

count=0;
for i = 1:130
    %stimList
    if runsCONew(i) == 0 % rest period 
        eyesType = restOrd(1);
        stimList = vertcat(stimList, {i '0' 'rest' eyesType '0' '0' '0' '0'...
            '0' '0' '0' '0' corrAns(i)}); 
        restOrd(1) = [];
    else

    % trial, condType, cond, words (4:10), yesP, noP, noTrialInd
    if runsCONew(i) == 1 % AW  
        if corrAns(i) == 2 
            noP = noProbes(noProbeInd(1)); 
            noProbeInd(1) = [];
        else 
            noP = AWrand(1); 
        end 
        stimList = vertcat(stimList, {i '1' 'AW' AWrand(1)...
            AWlist{AWrand(1),2} AWlist{AWrand(1),3} AWlist{AWrand(1),4}...
            AWlist{AWrand(1),5} AWlist{AWrand(1),6} AWlist{AWrand(1),7}...
            AWrand(1) noP corrAns(i)}); 
        AWrand(1) = []; 
    end 
    if runsCONew(i) == 2 % AB 
        stimList = vertcat(stimList, {i '2' 'AB' ABrand(1)...
            ABlist{ABrand(1),2} ABlist{ABrand(1),3} ABlist{ABrand(1),4}...
            ABlist{ABrand(1),5} ABlist{ABrand(1),6} ABlist{ABrand(1),7}...
            ABrand(1) ABrand(1) corrAns(i)}); 
        ABrand(1) = []; 
    end 
    if runsCONew(i) == 3 % VW
        if corrAns(i) == 2 
            noP = noProbes(noProbeInd(1)); 
            noProbeInd(1) = []
        else 
            noP = VWrand(1); 
        end 
        stimList = vertcat(stimList, {i '3' 'VW' VWrand(1)...
            VWlist{VWrand(1),2} VWlist{VWrand(1),3} VWlist{VWrand(1),4}...
            VWlist{VWrand(1),5} VWlist{VWrand(1),6} VWlist{VWrand(1),7}...
            VWrand(1) noP corrAns(i)}); 
        VWrand(1) = [];
    end 
    if runsCONew(i) == 4 % CS 
        stimList = vertcat(stimList, {i '4' 'CS' CSrand(1) ...
            CSlist{CSrand(1),2} CSlist{CSrand(1),3} CSlist{CSrand(1),4}...
            CSlist{CSrand(1),5} CSlist{CSrand(1),6} CSlist{CSrand(1),7}...
            CSrand(1) CSrand(1) corrAns(i)}); 
        CSrand(1) = [];  
    end
    if runsCONew(i) == 5 % SH
        stimList = vertcat(stimList, {i '5' 'FF' FFrand(1) ...
            FFlist{FFrand(1),2} FFlist{FFrand(1),3} FFlist{FFrand(1),4}...
            FFlist{FFrand(1),5} FFlist{FFrand(1),6} FFlist{FFrand(1),7}...
            FFrand(1) FFrand(1) corrAns(i)}); 
        FFrand(1) = [];   
    end 
    end
end 
%}
% NOTE: Slightly confusing... the third column of stimList --> for AW and
% AB, the number indexes the actual sound file number. For VW, FF, and CS,
% it indexes just a random number between 1-20 (and the image files
% correspond to 1-20). I have to be careful to add to directory: Group 1
% for AW & AB, and Group 2 of VW (and vice versa). 

cell2csv([dir.trials filesep file.trials_csv], stimList, ','); 
save([dir.trials filesep file.trials_mat], 'stimList'); 

