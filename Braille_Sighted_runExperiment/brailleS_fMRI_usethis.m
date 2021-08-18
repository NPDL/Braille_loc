
%% New Version of Braille Sighted Experiment 
% 10/24/15 by Judy Kim 
% Refer to "brailleS_notes_102915.txt" for exact design 

function brailleS_fMRI(SUBJ_ID,GROUP,RUN,EYES) % Cedrus only version 
% example input: brailleS_fMRI_usethis('brailleS_fMRI_01',1,1,'open')

%% DIRECTORIES & FILES 

% A separate directory for data, stimuli, and trial orders 
dir.data = [pwd '/brailleS_data'];
dir.stim = [pwd '/brailleS_stim'];  
dir.trials = [pwd '/brailleS_trials']; 
% If group entered is 1, then groupB is the other set of words (i.e., 2)
if GROUP == 1; groupB = 2; else groupB = 1; end
% AW/AB should be group, and VW is groupB; CS and FF only have one version 
dir.stim_AB = [dir.stim '/brailleS_AB/Group' num2str(GROUP) '_AB']; 
dir.stim_AW = [dir.stim '/brailleS_AW/Group' num2str(GROUP) '_AW']; 
    dir.stim_VW = [dir.stim '/brailleS_VW/Group' num2str(groupB) '_VW']; 
dir.stim_CS = [dir.stim '/brailleS_CS']; 
dir.stim_FF = [dir.stim '/brailleS_FF'];  
dir.stim_prompts = [dir.stim '/brailleS_prompts']; 
% Removing first to make sure, then adding back stim subfolders
rmpath(dir.stim) 
addpath(genpath(dir.stim_AW)); addpath(genpath(dir.stim_AB));
addpath(genpath(dir.stim_VW)); addpath(genpath(dir.stim_CS)); 
addpath(genpath(dir.stim_FF)); addpath(genpath(dir.stim_prompts)); 
% File names for saving, example of root: 'brailleS_fMRI_01_grp1_run1'
rootName = ['brailleS_' SUBJ_ID '_grp' num2str(GROUP) '_run' num2str(RUN)]
fileN.final_csv = [rootName 'final.csv']; fileN.final_mat = [rootName 'final.mat'];
% Error message if data file already exists
if exist([dir.data filesep fileN.final_csv],'file') || exist([dir.data filesep fileN.final_mat],'file')
    error('The data file already exists for this subject! \n'); 
end 

%% CHECK CEDRUS BOX/KEYBAORD

% Yes, No, Scanner Trigger 
yesButton = 1; noButton = 2; triggerButton = 6; 

% Keyboard set-up 
KbName('UnifyKeyNames');
pauseKey = KbName('p'); 
continueKey = KbName('c');  % this should be 44 
quitKey = KbName('ESCAPE'); % this should be 41 
keysAll = [pauseKey continueKey quitKey]; 

% Open and close Cedrus once to check 
global cedrus
if isstruct(cedrus) && isfield(cedrus, 'port') 
    fprintf('Cedrus already open. Reopening once. \n'); 
    cedrus.close(); 
end 
cedrusopen 
cedrus.resettimer();

%% SCREEN/SOUND SETUP

% Initialize Screen 
clear ('CloseAll') 
Screen('Preference','SkipSyncTests',1); % VBLSync still fails!! (Matlab 2014a) 
SCREEN_NUM = max(Screen('Screens'));
[window,rect] = Screen('OpenWindow',SCREEN_NUM,1); 
white = WhiteIndex(SCREEN_NUM); % Pixel value for white
black = BlackIndex(SCREEN_NUM); % Pixel value for black 
% Initialize PsychPortAudio
PsychPortAudio('Close') % if you don't do this, audio won't play with too many channels open
InitializePsychSound; 

%% GENERATE TRIAL LISTS

% Generate one list of trials (26 x 5 = 130) for first run  
conds = {'AW','AB','vw','cs','ff'}; 
rootNameS = ['brailleS_' SUBJ_ID '_grp' num2str(GROUP)]; 
file.trials_mat = [rootNameS '_trials.mat']; 
% Warn if file already exists
if RUN == 1 
    if exist([dir.trials filesep file.trials_mat],'file')
        fprintf('Trials file for this subject were already generated. Not generating a new order. \n This is probably not right. \n'); 
    else
        genBrailleSTrials_try(SUBJ_ID,GROUP,EYES); 
    end
end 
% In the subsequent runs, load from this original trials list
load([dir.trials filesep file.trials_mat], 'stimList'); % a 130x13 matrix 

%% LOAD AUDIO FILES 

% Load files for this run (26 trials) 
startTrial = (RUN-1)*26+1; endTrial = (RUN-1)*26+26; 
% This is the 26 x 14 stimList for the single run  
orgStimList = stimList; % safekeeping
stimList = orgStimList(startTrial:endTrial,:); 
NUM_STIMULI = size(stimList,1);
% Load all stimuli for this run 
for i = 1:26
    if str2num(stimList{i,2}) > 0 % if not rest 
        cond = conds{str2num(stimList{i,2})};
    end
    if stimList{i,13} == 1 % yes or no probe
        probeType = 'y'; 
        probeInd = stimList{i,11}; 
    else
        probeType = 'n';
        probeInd = stimList{i,12}; 
    end 
    if str2num(stimList{i,2}) == 1 || str2num(stimList{i,2}) == 2 % AW or AB
        % reminder: stimList{i,4} is the file number
        % for AB, CS, FF, yes and no probes are both fixed 
        % for VW and AW, yes probes are fixed, but no probes are half/half 
        for k = 1:6 
            audioFile{i,k} = sprintf('%s_%d_%d.wav',cond,stimList{i,4},k); 
            [audio_h{i,k},audio_d{i,k},audio_y{i,k}] = loadAudio(audioFile{i,k}); 
            PsychPortAudio('FillBuffer',audio_h{i,k},audio_y{i,k}'); 
        end 
        audioProbes{i} = sprintf('%s%sp_%d.wav',cond,probeType,probeInd);
        [audioProbes_h{i},audioProbes_d{i},audioProbes_y{i}] = loadAudio(audioProbes{i}); 
        PsychPortAudio('FillBuffer',audioProbes_h{i},audioProbes_y{i}'); 
    end
    if str2num(stimList{i,2}) > 2  % visual conditions, VW/CS/FF
        mag = 1.5; % from Helvetica 90*1.5=135 
        for j = 1:6 % shImg --> just lazy to change the names, refers to all images
            strImg{i,j}= imread(sprintf('%s_%d_%d.png',cond,stimList{i,4},j),'png'); 
            strNewImg{i,j} = imresize(strImg{i,j},mag);
        end
        strProbeImg{i} = imread(sprintf('%s%sp_%d.png',cond,probeType,probeInd),'png');
        strProbeNewImg{i}  = imresize(strProbeImg{i},mag);
    end 
end 

% Load prompt sound files 
prompts = {'beep_low' 'Listen_new' 'Look_new' 'click'};  
for i = 1:4 
    promptFile = sprintf('%s.wav',prompts{i});  
    [prompt_h{i},prompt_d{i},prompt_y{i}] = loadAudio(promptFile); 
    PsychPortAudio('FillBuffer',prompt_h{i},prompt_y{i}'); 
end

%% INITIALZIE DATA RECORDER 

subjData = cell(size(stimList,1)+1,9); 
subjData(1,:) = {'Subj','Group','Run','Cond','File','Dur','Resp','RT','Acc'}; 
subjData(2:end,1) = {SUBJ_ID}; 
subjData(2:end,2) = {GROUP}; 
subjData(2:end,3) = {RUN};
subjData(2:end,4) = stimList(:,3); % conditions
subjData(2:end,5) = stimList(:,4); % audio/image file name 
subjData(2:end,6) = {0}; % total trial duration 
subjData(2:end,7) = {NaN}; % response
subjData(2:end,8) = {0}; % RT
subjData(2:end,9) = {0};  % accuracy 

%% DURATIONS 

dur.cue = 0.5; 
dur.stim_total = 10.5; % need to change back to 16.65
dur.stim_each = dur.stim_total/6; % 2.75, but images are on only for 2s  
dur.img = 1; 
dur.delay = 0.2; % delay and then beep
dur.beep = 0.5; 
dur.resp_window = 5.3; % this includes probe 
dur.rest = 16; 
dur.trial = 17; 

%% START SCREEN 

Screen('FillRect',window,white); 
Screen('TextFont',window,'Helvetica');
Screen('TextSize',window,50);
Screen('TextStyle',window,0);
instructions = 'The experiment is about to begin. \n Please get ready.'; 
DrawFormattedText(window, instructions, 'center', 'center', black);  
HideCursor; 
Screen('Flip',window); 

while 1 
     [keyIsDown,seconds,keyCode] = KbCheck; 
     if keyIsDown == 1 
         break 
     end 
end 

keyIsDown = 0; seconds = []; keyCode = [];

%% WAIT FOR SCANNER TRIGGER 

Screen('FillRect',window,white); 
waitMsg = 'Experiment starting now...';
DrawFormattedText(window, waitMsg, 'center', 'center', black); 
Screen('Flip',window); 

cButton = 0; 
while 1 
    [cButton cTime cPress] = getCedrusResponse;
    if cButton == 6 % scanner trigger 
        Screen('FillRect',window,white); 
        Screen('Flip',window); 
        WaitSecs(2)
        break
    end 
end 


%% START EXPERIMENT 
keyIsDown = 0; seconds = 0; keyCode = 0; pause_or_quit = 0;
RT_raw = zeros(26,1);

z = zeros(26,1)'; z2 = repmat(z,6,1);
t = struct('exp_start',z,'trial_start',z,'prompt_start',z,'prompt_max',z,'prompt_end',z, ...
    'prompt_realDur',z,'stim_start',z,'word_start',z2,'word_max',z2,'word_end',z2,'word_realDur',z2, ...
    'word_start2',z2,'word_max2',z2,'word_end2',z2,'stim_end',z,'stim_realDur',z,'blank_start',z, ...
    'blank_max',z,'blank_end',z,'blank_realDur',z,'beep_start',z,'beep_max',z,'beep_end',z, ...
    'beep_realDur',z,'probe_start',z,'probe_max',z,'resp_start',z,...
    'maxSecs',z,'resp_end',z,'probe_flipped',z,'trial_end',z,'trial_realDur',z,'rest_start',z, ...
    'rest_max',z,'rest_end',z,'rest_realDur',z); 

%try    
    
    tic
    t.exp_start = GetSecs; 
    pause_or_quit = 0 ; 
    
    
    for trial = 1:NUM_STIMULI 
        t.trial_start(trial) = GetSecs; 
        clear curtex;  
        
                pause_or_quit = getKeyResponse; 
                if pause_or_quit == 1 
                    break 
                end 
        
        % 1. If rest trial, blank for 16 seconds 
        if str2num(stimList{trial,2}) == 0 % for just rest... 16 seconds of nothing
            if stimList{trial,4} == 1 % open first, so white 
                restColor = white; 
            else
                restColor = black;
            end
            Screen('FillRect',window,restColor);
            Screen('Flip',window);
            t.rest_start(trial) = GetSecs; % start recording after flip has started 
            t.rest_max(trial) = t.rest_start(trial) + dur.rest; 
            WaitSecs(t.rest_max(trial) - GetSecs);
            t.rest_end(trial) = GetSecs; 
            t.rest_realDur(trial) = t.rest_end(trial) - t.rest_start(trial)
        else
        % 2. Play AB or AW files
        if str2num(stimList{trial,2}) == 1 || str2num(stimList{trial,2}) == 2               
            Screen('FillRect',window,black)
            Screen('Flip',window) 
            % Play "Listen" prompt
            t.prompt_start(trial) = GetSecs; 
            PsychPortAudio('Start', prompt_h{2},1);
            t.prompt_max(trial) = t.prompt_start(trial) + dur.cue; 
            WaitSecs(t.prompt_max(trial) - GetSecs);
            t.prompt_end(trial) = GetSecs; 
            t.prompt_realDur(trial) = t.prompt_end(trial) - t.prompt_start(trial)

            t.stim_start(trial) = GetSecs; 
   
            % Play audio files 
            for j = 1:6 
                t.word_start(j,trial) = GetSecs; 
                PsychPortAudio('Start',audio_h{trial,j},1);
                WaitSecs(audio_d{trial,j});
                t.word_max(j,trial) = t.word_start(j,trial) + dur.stim_each; 
                WaitSecs(t.word_max(j,trial) - GetSecs); 
                t.word_end(j,trial) = GetSecs; 
                t.word_realDur(j,trial) = t.word_end(j,trial) - t.word_start(j,trial)
            end 
            t.stim_end(trial) = GetSecs; 
            t.stim_realDur(trial) = t.stim_end(trial) - t.stim_start(trial) 

            % Short blank delay  
            t.blank_start(trial) = GetSecs; 
            t.blank_max(trial) = t.blank_start(trial) + dur.delay; 
            WaitSecs(t.blank_max(trial) - GetSecs); 
            t.blank_end(trial) = GetSecs; 
            t.blank_realDur(trial) = t.blank_end(trial) - t.blank_start(trial) 

            % Play beep
            t.beep_start(trial) = GetSecs; 
            t.beep_max(trial) = t.beep_start(trial) + dur.beep; 
            PsychPortAudio('Start',prompt_h{1},1);  
            WaitSecs(t.beep_max(trial) - GetSecs); 
            t.beep_end(trial) = GetSecs; 
            t.beep_realDur(trial) = t.beep_end(trial) - t.beep_start(trial)
            % Play probe 
            t.probe_start(trial) = GetSecs; 
            PsychPortAudio('Start',audioProbes_h{trial}); 
            
        % 3. Display VW, CS, or FF
        elseif str2num(stimList{trial,2}) > 2     
            % Play "Look" prompt 
            Screen('FillRect',window,white); 
            Screen('Flip',window);
            t.prompt_start(trial) = GetSecs; 
            PsychPortAudio('Start', prompt_h{3}, 1);
            t.prompt_max(trial) = t.prompt_start(trial) + dur.cue; 
            WaitSecs(t.prompt_max(trial) - GetSecs); 
            t.prompt_end(trial) = GetSecs; 
            t.prompt_realDur(trial) = t.prompt_end(trial) - t.prompt_start(trial) 

            t.stim_start(trial) = GetSecs;
            % Display images 
            for j = 1:6 
                currImg = strNewImg{trial,j}; 
                curtex1 = Screen('MakeTexture', window, currImg);
                Screen('FillRect',window,white);
                Screen('DrawTexture',window,curtex1);
                Screen('Flip',window);
                t.word_start(j,trial) = GetSecs;
                t.word_max(j,trial) = t.word_start(j,trial) + dur.img; 
                WaitSecs(t.word_max(j,trial) - t.word_start(j,trial))
                t.word_end(j,trial) = GetSecs;
                t.word_realDur(j,trial) = t.word_end(j,trial) - t.word_start(j,trial)
                Screen('FillRect',window,white);
                Screen('Flip',window); 
                t.word_start2(j,trial) = GetSecs; 
                t.word_max2(j,trial) = t.word_start(j,trial) + dur.stim_each - 0.013; 
                WaitSecs(t.word_max2(j,trial) - t.word_start2(j,trial));
                t.word_end2(j,trial) = GetSecs; 
                t.word_realDur2(j,trial) = t.word_end2(j,trial) - t.word_start(j,trial)   
            end 
            t.stim_end(trial) = GetSecs; 
            t.stim_realDur(trial) = t.stim_end(trial) - t.stim_start(trial); 
            
            % Short blank delay 
            Screen('FillRect',window,white);
            Screen('Flip',window);
            t.blank_start(trial) = GetSecs; 
            t.blank_max(trial) = t.blank_start(trial) + dur.delay; 
            WaitSecs(t.blank_max(trial) - GetSecs); 
            t.blank_end(trial) = GetSecs; 
            t.blank_realDur(trial) = t.blank_end(trial) - t.blank_start(trial)

            % Play beep - no need to flip again 
            t.beep_start(trial) = GetSecs;
            t.beep_max(trial) = t.beep_start(trial) + dur.beep; 
            PsychPortAudio('Start',prompt_h{1},1);  
            WaitSecs(t.beep_max(trial) - GetSecs); 
            t.beep_end(trial) = GetSecs; 
            t.beep_realDur(trial) = t.beep_end(trial) - t.beep_start(trial) 
            
            % Display probe 
            probeImg = strProbeNewImg{trial};
            curtex2 = Screen('MakeTexture', window, probeImg);
            Screen('FillRect',window,white);
            Screen('DrawTexture',window,curtex2);
            Screen('Flip',window);  
            t.probe_start(trial) = GetSecs; 
            t.probe_max(trial) = t.probe_start(trial) + dur.img;       
        end 
        
            % Just checking if pause or quit
                pause_or_quit = getKeyResponse; 
                if pause_or_quit == 1 
                    break 
                end 
            
            % Start recording responses 
            button = 0; time = 0; press = 0; cedrus.count = 0;
            cButton = 0; cTime = 0; cPress = 0; cRT = 0;
            cedrus.resettimer();
            
            t.resp_start(trial) = GetSecs; 
            t.maxSecs(trial) = t.trial_start(trial) + dur.trial;
 
            % for auditory, ended only with t.probe_start{trial}, and then
            % playing the sound file for however long 
            flipped = 0; 
            while GetSecs < t.maxSecs(trial)
                if str2num(stimList{trial,2}) > 2
                    if t.probe_max(trial) < GetSecs && flipped == 0 
                        Screen('FillRect',window,white);
                        Screen('Flip',window);
                        t.probe_flipped(trial) = GetSecs
                        flipped = 1
                    end
                end
                if button == 0
                    [cButton cTime cPress] = getCedrusResponse;  
                    button = cButton;  
                    RT_raw(trial) = cTime; 
                    if button ~= 0 
                        subjData(trial+1,7) = {button};
                        subjData(trial+1,8) = {RT_raw(trial)};
                        if button == stimList{trial,13}    
                           subjData(trial+1,9) = {1};
                        end
                        t.resp_end(trial) = GetSecs;
                    end
                end
            end 
            WaitSecs(t.maxSecs(trial)-GetSecs-2); % the minus two is there because... for loop 
        end
            t.trial_end(trial) = GetSecs;
            t.trial_realDur(trial) = t.trial_end(trial) - t.trial_start(trial)
            subjData(trial+1,6) = {t.trial_realDur(trial)}; 
    end 
    toc
    t
    subjData
   
    % Calculating performance 
    [sumMat pctCorrect meanRT] = sumResponses(subjData); 
    sumData = {}; 
    sumData(1,1:4) = {'Condition','Mean RT','STD','Accuracy'}; 
    sumData(2,1) = {'VW'}; 
    sumData(3,1) = {'CS'}; 
    sumData(4,1) = {'FF'}; 
    sumData(5,1) = {'AW'}; 
    sumData(6,1) = {'AB'}; 
    sumData(2:6,2:4) = num2cell(sumMat); 
    
    sumData
   
    % Print out some information 
    fprintf('Total Run Time in Seconds: %f \n',toc); 
    fprintf('%.3f% \n correct, mean RT: %.3f seconds. \n',pctCorrect,meanRT); 
    
    Screen('FillRect',window,white);
    endMsg = sprintf('End of run %d!',RUN); 
    DrawFormattedText(window,endMsg,'center','center',black); 
    Screen('Flip',window); 
    
    cell2csv([dir.data filesep rootName 'final.csv'],subjData);
    save([dir.data filesep rootName 'final.mat'],'subjData','sumData','t'); 
    WaitSecs(2);
    Screen('CloseAll'); 
    ShowCursor
    return
%{
catch
    fprintf('Error inside function. Saving under errorOut.mat')
    cell2csv([dir.data filesep rootName 'errorAtTrial' trial '.csv'],subjData); 
    save([dir.data filesep rootName 'errorAtTrial' trial '.mat'],'subjData','t'); 
end
%}

%% SUBFUNCTIONS

function out = getKeyResponse  
    [keyIsDown,seconds,keyCode] = KbCheck(-1)
    if keyIsDown 
        response = find(keyCode);
        if response == pauseKey % Pause
            Screen('FillRect',window,white);
            pauseMsg = 'Experiment paused. \n Press C to continue or ESC to quit. \n'
            DrawFormattedText(window, pauseMsg, 'center', 'center', black);  
            Screen('Flip',window);
            cell2csv([dir.data filesep rootName 'pausedAtTrial' trial '.csv'],subjData); 
            save([dir.data filesep rootName 'pausedAtTrial' trial '.mat'],'subjData','t'); 
            KbWait;  
            while 1   
                [kId,sec,kC] = KbCheck; 
                if kId 
                    resp = find(kC); 
                    if resp == continueKey % Continue 
                        contMsg = sprintf('Experiment continuing from trial %d', trial+1)
                        Screen('FillRect',window,white);
                        DrawFormattedText(window, contMsg, 'center', 'center', black);
                        Screen('Flip',window); 
                        WaitSecs(3)
                        out = 0;
                        return
                    elseif resp == quitKey % Quit after pause 
                        quitMsg = sprintf('Experiment quit at trial %d', trial) 
                        Screen('FillRect',window,white);
                        DrawFormattedText(window, quitMsg, 'center', 'center', black);  
                        Screen('Flip',window);
                        cell2csv([dir.data filesep rootName 'quitAtTrial' trial '.csv'],subjData); 
                        save([dir.data filesep rootName 'quitAtTrial' trial '.mat'],'subjData','t'); 
                        Screen('CloseAll');
                        ShowCursor
                        out = 1;
                        return
                    end 
                end 
            end 
        elseif response == quitKey % Quit 
            quitMsg = sprintf('Experiment quit at trial %d', trial) 
            Screen('FillRect',window,white);
            DrawFormattedText(window, quitMsg, 'center', 'center', black);  
            Screen('Flip',window);
            WaitSecs(5)
            out = 1;
            cell2csv([dir.data filesep rootName 'quitAtTrial' trial '.csv'],subjData); 
            save([dir.data filesep rootName 'quitAtTrial' trial '.mat'],'subjData','t'); 
            Screen('CloseAll');
            ShowCursor
            return
        end 
    else 
        out = 0; 
    end 
end 

function [cButton cTime cPress] = getCedrusResponse 
   cButton = 0; cTime = 0; cPress = 0; % cRT = 0;
   [button time press] = cedrus.getpress();
       if press ~= 0 
           cButton = button; 
           cTime = time;
           cPress = press;  
           % cRT = GetSecs(); 
       end 
end

function [outMat pctCorrect meanRT] = sumResponses(data) 
    conds = {'VW','CS','FF','AW','AB'}; 
    outMat = NaN(numel(conds),3); 
    condInd = data(2:end,4);
    rts = cell2mat(data(2:end,8)); 
    accuracy = cell2mat(data(2:end,9)); 
    for ind = 1:numel(conds) 
        conds{ind};
        found = find(strcmp(condInd,conds{ind}));
        found2 = found(find(accuracy(found)));
        outMat(ind,1) = mean(rts(found2),1) % only correct
        outMat(ind,2) = std(rts(found2));
        outMat(ind,3) = length(found2)/4 ;
    end
    pctCorrect = mean(accuracy)*100; 
    meanRT = mean(rts); 
end

function [audio_handle, audio_dur, audio_y] = loadAudio(audioFile)
   [audio_y, audio_freq] = audioread(audioFile); 
   audio_dur = length(audio_y(:,:))/audio_freq(:,:); 
   audio_chs = size(audio_y',1);
   %audio_handle = PsychPortAudio('Open',[],[],2,[],audio_chs); 
   audio_handle = PsychPortAudio('Open',[],[],1,[],audio_chs); 
end        

end   






