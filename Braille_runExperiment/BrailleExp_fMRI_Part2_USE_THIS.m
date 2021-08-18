% CHANGE LOG: 191125: all instances of "PsychPortAudio('Open', [], [], 2,
% freq_beep_low, chs_beep_low)" changed to "PsychPortAudio('Open', [], [],
% 1, freq_beep_low, chs_beep_low)". The "reqlatencyclass" argument is set
% to 1 so as not to take full and exclusive control of the playback device

% 200104 note: should execute this script in the parent folder 
% ([whatever path]\BrailleExp_fromStimLaptop1)
% and select "add to path" when prompted
% 200106: prune commented-out lines and disconnected variables

% 200107:
% ** use the latest version of cedrusopen as I'm using in the TWFA main exp
% ** don't use "WaitSec" after "getpress"! For some reason, the wait time will be added to
% the response time. U

%% INITIALIZE
close all;
PsychDefaultSetup(2); % 200105
InitializePsychSound;
KbName('UnifyKeyNames');
rand('twister',sum(100*clock))
commandwindow
trigger = 6;

%% GET SUBJECT INFO

prompt = {'Subject Number';'Run #';'Group';'Random state'};
def = {'';'1,2,3,4,5';'1 or 2';'X'};
% a random state should be specified everytime MATLAB is restarted,
% including the first run.
% if the 2nd - 5th runs are executed without restarting MATLAB,
% the random state should be X.
% If some errors happen after the cmd window says "Saving stimulus information",
% and MATLAB isn't restarted, when rerunning the run, random state should be X
answer = inputdlg(prompt, 'Experimental setup',1,def);
[sub run group rand_state] = deal(answer{:});
run=str2double(run);
group=strcat('Group',group);
if rand_state~='X'
	rand('state',str2num(rand_state))
	fprintf('Random state is set to %s\n',rand_state)
end

%% PATHS
%Root Path
path_root = 'C:/Users/testing5/Dropbox/Yun-Fei.Brianna.Marina/Braille RSA/Yunfei_Braille/BrailleExp_fromStimLaptop1/BrailleExp_Part2_';
name_root = 'BrailleExp_Part2_';

%Folder Paths
path_stim = strcat(path_root,'Stim/',group,'/');
path_data = strcat(path_root,'Results/');
path_prompt = strcat(path_root,'Prompts/');
path_files = strcat(path_root,'Files/');

%Sub-folder Paths
path_stim_awl_timing = strcat(path_stim,name_root,'Stim_Audio_WL_Timing/');
path_stim_awl = strcat(path_stim,name_root,'Stim_Audio_WL/');
path_stim_awl_yp = strcat(path_stim,name_root,'Stim_Audio_WL_YP/');
path_stim_awl_np = strcat(path_stim,name_root,'Stim_Audio_WL_NP/');
path_stim_abs_timing = strcat(path_stim,name_root,'Stim_Audio_BS_Timing/');
path_stim_abs = strcat(path_stim,name_root,'Stim_Audio_BS/');
path_stim_abs_yp = strcat(path_stim,name_root,'Stim_Audio_BS_YP/');
path_stim_abs_np = strcat(path_stim,name_root,'Stim_Audio_BS_NP/');
path_stim_bwl = strcat(path_stim,name_root,'Stim_Braille_WL/');
path_stim_bwl_yp = strcat(path_stim,name_root,'Stim_Braille_WL_YP/');
path_stim_bwl_np = strcat(path_stim,name_root,'Stim_Braille_WL_NP/');
path_stim_bcs = strcat(path_stim,name_root,'Stim_Braille_CS/');
path_stim_bcs_yp = strcat(path_stim,name_root,'Stim_Braille_CS_YP/');
path_stim_bcs_np = strcat(path_stim,name_root,'Stim_Braille_CS_NP/');
path_stim_bss = strcat(path_stim,name_root,'Stim_Braille_SS/');
path_stim_bss_yp = strcat(path_stim,name_root,'Stim_Braille_SS_YP/');
path_stim_bss_np = strcat(path_stim,name_root,'Stim_Braille_SS_NP/');

%Relevant Files
fn_runformat = strcat(path_files,name_root,'RunFormat_5Cond.xlsx');

%Output
fn_data_xls = strcat(path_data,strcat(sub,'_','BrailleExp_Part2_','R',num2str(run),'_',datestr(now, 'yymmdd'),'_Data','.xls'));
% fn_data_mat = strcat(path_data,strcat(sub,'_','BrailleExp_Part2_','R',num2str(run),'_',datestr(now, 'yymmdd'),'_Data','.mat'));
% why do I need to save such huge data?
% fn_stim_mat = strcat(path_data,strcat(sub,'_','BrailleExp_Part2_','R',num2str(run),'_',datestr(now, 'yymmdd'),'_Stim','.mat'));
% fn_info = strcat(path_data,strcat(sub,'_','BrailleExp_Part2_','info','_',datestr(now, 'yymmdd'),'.mat'));
% why should I save such huge data?

%% PROMPTS
ifn = 'Incorrect_6.wav';
[y_i,freq_i] = audioread(char(strcat(path_prompt,ifn)));
ifb = audioplayer(y_i,freq_i);
difb = (length(y_i)) ./ (freq_i);

cfn = 'Correct_6.wav';
[y_c,freq_c] = audioread(char(strcat(path_prompt,cfn)));
cfb = audioplayer(y_c,freq_c);
dcfb = (length(y_c)) ./ (freq_c);

beepfn = 'beep_high.wav';
[y_beep,freq_beep] = audioread(char(strcat(path_prompt,beepfn)));
beep = audioplayer(y_beep,freq_beep);
dbeep = (length(y_beep)) ./ (freq_beep);

beep_low_fn = 'beep_low.wav';
[y_beep_low,freq_beep_low] = audioread(char(strcat(path_prompt,beep_low_fn)));
beep_low = audioplayer(y_beep_low,freq_beep_low);
dbeep_low = (length(y_beep_low)) ./ (freq_beep_low);
chs_beep_low = size(y_beep_low',1); 
try
	hndle_beep_low = PsychPortAudio('Open', [], [], 0, freq_beep_low, chs_beep_low);
	
catch
	fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq_beep_low);
	fprintf('Sound may sound a bit out of tune, ...\n\n');

	psychlasterror('reset');
	hndle_beep_low = PsychPortAudio('Open', [], [], 0, [], chs_beep_low);
end
PsychPortAudio('FillBuffer', hndle_beep_low, y_beep_low');

lfn = 'Listen.wav';
[y_l,freq_l] = audioread(char(strcat(path_prompt,lfn)));
listen = audioplayer(y_l,freq_l);
dlisten = (length(y_l)) ./ (freq_l);
chs_listen = size(y_l',1); 
try
	hndle_listen = PsychPortAudio('Open', [], [], 0, freq_l, chs_listen);
catch
	fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq_l);
	fprintf('Sound may sound a bit out of tune, ...\n\n');

	psychlasterror('reset');
	hndle_listen = PsychPortAudio('Open', [], [], 0, [], chs_listen);
end
PsychPortAudio('FillBuffer', hndle_listen, y_l');

tfn = 'Touch.wav';
[y_t,freq_t] = audioread(char(strcat(path_prompt,tfn)));
touch = audioplayer(y_t,freq_t);
dtouch = (length(y_t)) ./ (freq_t);
chs_touch = size(y_t',1); 
try
	hndle_touch = PsychPortAudio('Open', [], [], 0, freq_t, chs_touch);
catch
	fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq_t);
	fprintf('Sound may sound a bit out of tune, ...\n\n');

	psychlasterror('reset');
	hndle_touch = PsychPortAudio('Open', [], [], 0, [], chs_touch);
end
PsychPortAudio('FillBuffer', hndle_touch, y_t');
 
%% TIMING
dur_stim1 = 16.5;
% dur_braille = 40;
dur_bstim1 = 2; % should be 2; old: 1.5
dur_int = .25;
dur_resp = 5.3;
% dur_cue = .5; % used to exist in old script, but not used
dur_trial = 31.6; % this isn't used in the script eventually
dur_rest = 16; 
dur_audpad = .01;
dur_beep = .5; % old: 0.25
dur_bdbuf = 0.75; % should be 0.75; old: 0.5
dur_blank = 0.2; % should be 0.2; old: 0.25
dur_bprobe = 2; % should be 2; old: 1.5

% 200102: added
dur_brl_trial_empirical = 30.4; % and there are 12 brl trials
dur_aud_trial_empirical = 23.3; % and there are  8 aud trials
% it was 31.4 and 24.4 before I change all the WaitSecs into while loops
 

dur_bd_bstim1 = dur_bstim1*1000;
dur_bd_blank = dur_blank*1000;
dur_bd_bprobe = dur_bprobe*1000;


%% RUN INFORMATION
%1=aud wl, 2=aud bs, 3=braille wl, 4=braille cons.string, 5=shapes

run_fmt = xlsread(fn_runformat);

rest_idxs(run,:) = find(run_fmt(run,:)==0); %Same for every run, but if it wasn't the same for every run you should move this out of this "first run only" section

truns = size(run_fmt,1);
tcnds = length(unique(run_fmt))-1;

i=0;
for i=1:truns;
	cos(i,:) = run_fmt(i,(run_fmt(i,:)~=0));
end

% ttrls = size(cos,2);
ttrls = size(run_fmt,2);

%% GET FILES FROM FOLDERS

dirfiles_aw_full = dir([path_stim_awl,'*.wav']);

i=0;
for i=1:size(dirfiles_aw_full);
	dirfiles_aw_fns{i} = cellstr(dirfiles_aw_full(i).name);
end %AWL
% AWL = audio word list

dirfiles_awyp_full = dir([path_stim_awl_yp,'a*wav']);

i=0;
for i=1:size(dirfiles_awyp_full);
	dirfiles_awyp_fns{i} = cellstr(dirfiles_awyp_full(i).name);
end %AWL YP

dirfiles_awnp_full = dir([path_stim_awl_np,'a*wav']);

i=0;
for i=1:size(dirfiles_awnp_full);
	dirfiles_awnp_fns{i} = cellstr(dirfiles_awnp_full(i).name);
end %AWL NP

dirfiles_awt_full = dir([path_stim_awl_timing,'*.txt']);

i=0;
for i=1:size(dirfiles_awt_full);
	dirfiles_awt_fns{i} = cellstr(dirfiles_awt_full(i).name);
end %AWL Timing

dirfiles_ab_full = dir([path_stim_abs,'a*wav']);

i=0;
for i=1:size(dirfiles_ab_full);
	dirfiles_ab_fns{i} = cellstr(dirfiles_ab_full(i).name);
end %ABS
% ABS = audio backward string (?)

dirfiles_abyp_full = dir([path_stim_abs_yp,'a*wav']);

i=0;
for i=1:size(dirfiles_abyp_full);
	dirfiles_abyp_fns{i} = cellstr(dirfiles_abyp_full(i).name);
end %ABS YP

dirfiles_abnp_full = dir([path_stim_abs_np,'a*wav']);

i=0;
for i=1:size(dirfiles_abnp_full);
	dirfiles_abnp_fns{i} = cellstr(dirfiles_abnp_full(i).name);
end %ABS NP

dirfiles_abt_full = dir([path_stim_abs_timing,'*.txt']);

i=0;
for i=1:size(dirfiles_abt_full);
	dirfiles_abt_fns{i} = cellstr(dirfiles_abt_full(i).name);
end %ABS Timing

dirfiles_bw_full = dir(path_stim_bwl);

j=0;
i=0;
for i=1:size(dirfiles_bw_full);
	if strcmp(dirfiles_bw_full(i).name,'.') == 1 || strcmp(dirfiles_bw_full(i).name,'..') == 1 || strcmp(dirfiles_bw_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bw_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bw_fns{j} = cellstr(dirfiles_bw_full(i).name);
	end
end %BWL
% BWL = braille word list

dirfiles_bwyp_full = dir(path_stim_bwl_yp);

j=0;
i=0;
for i=1:size(dirfiles_bwyp_full);
	if strcmp(dirfiles_bwyp_full(i).name,'.') == 1 || strcmp(dirfiles_bwyp_full(i).name,'..') == 1 || strcmp(dirfiles_bwyp_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bwyp_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bwyp_fns{j} = cellstr(dirfiles_bwyp_full(i).name);
	end
end %BWL YP

dirfiles_bwnp_full = dir(path_stim_bwl_np);

j=0;
i=0;
for i=1:size(dirfiles_bwnp_full);
	if strcmp(dirfiles_bwnp_full(i).name,'.') == 1 || strcmp(dirfiles_bwnp_full(i).name,'..') == 1 || strcmp(dirfiles_bwnp_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bwnp_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bwnp_fns{j} = cellstr(dirfiles_bwnp_full(i).name);
	end
end %BWL NP

dirfiles_bc_full = dir(path_stim_bcs);

j=0;
i=0;
for i=1:size(dirfiles_bc_full);
	if strcmp(dirfiles_bc_full(i).name,'.') == 1 || strcmp(dirfiles_bc_full(i).name,'..') == 1 || strcmp(dirfiles_bc_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bc_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bc_fns{j} = cellstr(dirfiles_bc_full(i).name);
	end
end %BCS
% BCS = braille consonant string

dirfiles_bcyp_full = dir(path_stim_bcs_yp);

j=0;
i=0;
for i=1:size(dirfiles_bcyp_full);
	if strcmp(dirfiles_bcyp_full(i).name,'.') == 1 || strcmp(dirfiles_bcyp_full(i).name,'..') == 1 || strcmp(dirfiles_bcyp_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bcyp_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bcyp_fns{j} = cellstr(dirfiles_bcyp_full(i).name);
	end
end %BCS YP

dirfiles_bcnp_full = dir(path_stim_bcs_np);

j=0;
i=0;
for i=1:size(dirfiles_bcnp_full);
	if strcmp(dirfiles_bcnp_full(i).name,'.') == 1 || strcmp(dirfiles_bcnp_full(i).name,'..') == 1 || strcmp(dirfiles_bcnp_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bcnp_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bcnp_fns{j} = cellstr(dirfiles_bcnp_full(i).name);
	end
end %BCS NP

dirfiles_bs_full = dir(path_stim_bss);

j=0;
i=0;
for i=1:size(dirfiles_bs_full);
	if strcmp(dirfiles_bs_full(i).name,'.') == 1 || strcmp(dirfiles_bs_full(i).name,'..') == 1 || strcmp(dirfiles_bs_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bs_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bs_fns{j} = cellstr(dirfiles_bs_full(i).name);
	end
end %BSS
% BSS = braille shape string(?)

dirfiles_bsyp_full = dir(path_stim_bss_yp);

j=0;
i=0;
for i=1:size(dirfiles_bsyp_full);
	if strcmp(dirfiles_bsyp_full(i).name,'.') == 1 || strcmp(dirfiles_bsyp_full(i).name,'..') == 1 || strcmp(dirfiles_bsyp_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bsyp_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bsyp_fns{j} = cellstr(dirfiles_bsyp_full(i).name);
	end
end %BSS YP

dirfiles_bsnp_full = dir(path_stim_bss_np);

j=0;
i=0;
for i=1:size(dirfiles_bsnp_full);
	if strcmp(dirfiles_bsnp_full(i).name,'.') == 1 || strcmp(dirfiles_bsnp_full(i).name,'..') == 1 || strcmp(dirfiles_bsnp_full(i).name,'.DS_Store') == 1 || strcmp(dirfiles_bsnp_full(i).name(1),'.') == 1;
	else
		j=j+1;
		dirfiles_bsnp_fns{j} = cellstr(dirfiles_bsnp_full(i).name);
	end
end %BSS NP

%Randomize AWL
aw_fns_rand_ary = randperm(length(dirfiles_aw_fns));
aw_fns_rand = dirfiles_aw_fns(aw_fns_rand_ary);
awyp_fns_rand = dirfiles_awyp_fns(aw_fns_rand_ary);
awnp_fns_rand = dirfiles_awnp_fns(aw_fns_rand_ary);
awt_fns_rand = dirfiles_awt_fns(aw_fns_rand_ary);

%Randomize ABS
ab_fns_rand_ary = randperm(length(dirfiles_ab_fns));
ab_fns_rand = dirfiles_ab_fns(ab_fns_rand_ary);
abyp_fns_rand = dirfiles_abyp_fns(ab_fns_rand_ary);
abnp_fns_rand = dirfiles_abnp_fns(ab_fns_rand_ary);
abt_fns_rand = dirfiles_abt_fns(ab_fns_rand_ary);

%Randomize BWL
bw_fns_rand_ary = randperm(length(dirfiles_bw_fns));
bw_fns_rand = dirfiles_bw_fns(bw_fns_rand_ary);
bwyp_fns_rand = dirfiles_bwyp_fns(bw_fns_rand_ary);
bwnp_fns_rand = dirfiles_bwnp_fns(bw_fns_rand_ary);

%Randomize BCS
bc_fns_rand_ary = randperm(length(dirfiles_bc_fns));
bc_fns_rand = dirfiles_bc_fns(bc_fns_rand_ary);
bcyp_fns_rand = dirfiles_bcyp_fns(bc_fns_rand_ary);
bcnp_fns_rand = dirfiles_bcnp_fns(bc_fns_rand_ary);

%Randomize BSS
bs_fns_rand_ary = randperm(length(dirfiles_bs_fns));
bs_fns_rand = dirfiles_bs_fns(bs_fns_rand_ary);
bsyp_fns_rand = dirfiles_bsyp_fns(bs_fns_rand_ary);
bsnp_fns_rand = dirfiles_bsnp_fns(bs_fns_rand_ary);

%% SET UP STIMULI

if rand_state~='X'
   %% DETERMINE YES/NO TRIALS
   i=0;
   for i=1:truns;
		done=false;
		while done==false;
			c1=0;c2=0;c3=0;c4=0;c5=0;
			j=0;
			for j=1:tcnds;
				mc_aryt{i}(1:2,j) = 1;
				mc_aryt{i}(3:4,j) = 2;
				mc_aryt{i}(:,j) = mc_aryt{i}(randperm(size(mc_aryt{i},1)),j);
			end
			k=0;
			for k=1:size(cos,2);
				switch cos(i,k)
					case 1
						c1=c1+1;
						mc_ary(i,k) = mc_aryt{i}(c1,cos(i,k));
					case 2
						c2=c2+1;
						mc_ary(i,k) = mc_aryt{i}(c2,cos(i,k));
					case 3
						c3=c3+1;
						mc_ary(i,k) = mc_aryt{i}(c3,cos(i,k));
					case 4
						c4=c4+1;
						mc_ary(i,k) = mc_aryt{i}(c4,cos(i,k));
					case 5
						c5=c5+1;
						mc_ary(i,k) = mc_aryt{i}(c5,cos(i,k));
				end
			end
			if (any(diff([find(mc_ary(i,:)==1)])>3) == 0) && (any(diff([find(mc_ary(i,:)==2)])>3) == 0);
				done = true;
			else 
				done = false;
			end
		end
	end %Pseudorandomize--make sure no more than 3 yes/no in a row, same number of yes/no per condition per run
   
	%% SET UP AUDITORY 
	cntr_aw = 0;
	cntr_ab = 0;
	cntr_a = 0;
	i=0;
	for i=1:truns;
		j=0;
		j2=0;
		for j=1:ttrls;
			if run_fmt(i,j) == 0;
			else
				j2=j2+1;
			end
			if run_fmt(i,j)==1; %Auditory word list
				cntr_aw = cntr_aw+1;
				cntr_a=cntr_a+1;
				afn_full_1{i,j} = strcat(path_stim_awl,aw_fns_rand{cntr_aw});
				afn_short_1{i,j} = aw_fns_rand{cntr_aw};
				if mc_ary(i,j2) == 1; %Match
					afn_full_2{i,j} = strcat(path_stim_awl_yp,awyp_fns_rand{cntr_aw});
					afn_short_2{i,j} =  awyp_fns_rand{cntr_aw};
				elseif mc_ary(i,j2) == 2; %No Match
					afn_full_2{i,j} = strcat(path_stim_awl_np,awnp_fns_rand{cntr_aw});
					afn_short_2{i,j} =  awnp_fns_rand{cntr_aw};
				end
				[start,stop,event] = textread(char(strcat(path_stim_awl_timing,awt_fns_rand{cntr_aw})));
				nevents(i,j) = length(event);
			elseif run_fmt(i,j)==2; %Auditory backwards speech
				cntr_ab = cntr_ab+1;
				cntr_a=cntr_a+1;
				afn_full_1{i,j} = strcat(path_stim_abs,ab_fns_rand{cntr_ab});
				afn_short_1{i,j} = ab_fns_rand{cntr_ab};
				if mc_ary(i,j2) == 1; %Match
					afn_full_2{i,j} = strcat(path_stim_abs_yp,abyp_fns_rand{cntr_ab});
					afn_short_2{i,j} =  abyp_fns_rand{cntr_ab};
				elseif mc_ary(i,j2) == 2; %No Match
					afn_full_2{i,j} = strcat(path_stim_abs_np,abnp_fns_rand{cntr_ab});
					afn_short_2{i,j} =  abnp_fns_rand{cntr_ab};
				end
				[start,stop,event] = textread(char(strcat(path_stim_abs_timing,abt_fns_rand{cntr_ab})));
				nevents(i,j) = length(event);
			end
			
			if run_fmt(i,j)==1 || run_fmt(i,j)==2;
				[y1.(strcat('x_',num2str(cntr_a))),freq1.(strcat('x_',num2str(cntr_a)))] = audioread(char(afn_full_1{i,j}));
				afn_audio_1.(strcat('x_',num2str(cntr_a))) = audioplayer(y1.(strcat('x_',num2str(cntr_a))),freq1.(strcat('x_',num2str(cntr_a))));
				dur_audio_1.(strcat('x_',num2str(cntr_a))) = (length(y1.(strcat('x_',num2str(cntr_a))))) ./ (freq1.(strcat('x_',num2str(cntr_a))));

				[y2.(strcat('x_',num2str(cntr_a))),freq2.(strcat('x_',num2str(cntr_a)))] = audioread(char(afn_full_2{i,j}));
				afn_audio_2.(strcat('x_',num2str(cntr_a))) = audioplayer(y2.(strcat('x_',num2str(cntr_a))),freq2.(strcat('x_',num2str(cntr_a))));
				dur_audio_2.(strcat('x_',num2str(cntr_a))) = (length(y2.(strcat('x_',num2str(cntr_a))))) ./ (freq2.(strcat('x_',num2str(cntr_a))));

				chs_audio_2.(strcat('x_',num2str(cntr_a))) = size((y2.(strcat('x_',num2str(cntr_a))))',1); 

				try
					hndle_audio_2.(strcat('x_',num2str(cntr_a))) = PsychPortAudio('Open', [], [], 0, freq2.(strcat('x_',num2str(cntr_a))), chs_audio_2.(strcat('x_',num2str(cntr_a))));
				catch
					fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq2.(strcat('x_',num2str(cntr_a))));
				   fprintf('Sound may sound a bit out of tune, ...\n\n');

					psychlasterror('reset');
					hndle_audio_2.(strcat('x_',num2str(cntr_a))) = PsychPortAudio('Open', [], [], 0, [], chs_audio_2.(strcat('x_',num2str(cntr_a))));
				end
				PsychPortAudio('FillBuffer', hndle_audio_2.(strcat('x_',num2str(cntr_a))), (y2.(strcat('x_',num2str(cntr_a))))');

				g=0;
				for g=1:nevents(i,j)
					aud_timing_sec{cntr_a}(g,1) = start(g);
					aud_timing_sec{cntr_a}(g,2) = stop(g);
					aud_timing_sec{cntr_a}(g,3) = stop(g) - start(g);
					aud_timing_samp{cntr_a}(g,1) = (afn_audio_1.(strcat('x_',num2str(cntr_a))).SampleRate) * start(g);
					aud_timing_samp{cntr_a}(g,2) = (afn_audio_1.(strcat('x_',num2str(cntr_a))).SampleRate) * stop(g);
				end

				aud_timing{cntr_a}(1,1) = 1; %first sample needs to be 1

				dur_pause = (dur_stim1-dur_audio_1.(strcat('x_',num2str(cntr_a)))-(dur_audpad*nevents(i,j)));

				aud_timing_pause_sec{cntr_a} = dur_pause/(nevents(i,j)-1);

				clearvars start stop event
			end
		end
	end 

	%% SET UP BRAILLE 
	dispsz = [32 48]; 
	blank = ones(dispsz);

	cntr_bw = 0;
	cntr_bcs = 0;
	cntr_bss = 0;
	cntr_b = 0;
	cntr_bswnp=0;
	i=0;
	for i=1:truns;
		j=0;
		j2=0;
		for j=1:ttrls;
			if run_fmt(i,j) == 0;
			else
				j2=j2+1;
			end
			if run_fmt(i,j) == 3; %Braille word lists
				cntr_bw = cntr_bw + 1;
				bfn_full_1{i,j} = strcat(path_stim_bwl,bw_fns_rand{cntr_bw},'/');
				bfn_short_1{i,j} = bw_fns_rand{cntr_bw};
				if mc_ary(i,j2) == 1; %Match
					bfn_full_2{i,j} = strcat(path_stim_bwl_yp,bwyp_fns_rand{cntr_bw});
					bfn_short_2{i,j} = bwyp_fns_rand{cntr_bw};
				elseif mc_ary(i,j2) == 2; %No Match
					cntr_bswnp = cntr_bswnp + 1;
					bfn_full_2{i,j} = strcat(path_stim_bwl_np,bwnp_fns_rand{cntr_bw});
					bfn_short_2{i,j} = bwnp_fns_rand{cntr_bw};
				end
			elseif run_fmt(i,j) == 4; %Braille consonant strings
			cntr_bcs = cntr_bcs + 1;
			bfn_full_1{i,j} = strcat(path_stim_bcs,bc_fns_rand{cntr_bcs},'/');
			bfn_short_1{i,j} = bc_fns_rand{cntr_bcs};
				if mc_ary(i,j2) == 1; %Match
					bfn_full_2{i,j} = strcat(path_stim_bcs_yp,bcyp_fns_rand{cntr_bcs});
					bfn_short_2{i,j} = bcyp_fns_rand{cntr_bcs};
				elseif mc_ary(i,j2) == 2; %No Match
					bfn_full_2{i,j} = strcat(path_stim_bcs_np,bcnp_fns_rand{cntr_bcs});
					bfn_short_2{i,j} = bcnp_fns_rand{cntr_bcs};
				end
			elseif run_fmt(i,j) == 5; %Braille shapes
				cntr_bss = cntr_bss + 1;
				bfn_full_1{i,j} = strcat(path_stim_bss,bs_fns_rand{cntr_bss},'/');
				bfn_short_1{i,j} = bs_fns_rand{cntr_bss};
				if mc_ary(i,j2) == 1; %Match
					bfn_full_2{i,j} = strcat(path_stim_bss_yp,bsyp_fns_rand{cntr_bss});
					bfn_short_2{i,j} = bsyp_fns_rand{cntr_bss};
				elseif mc_ary(i,j2) == 2; %No Match
					bfn_full_2{i,j} = strcat(path_stim_bss_np,bsnp_fns_rand{cntr_bss});
					bfn_short_2{i,j} = bsnp_fns_rand{cntr_bss};
				end
			end

			if run_fmt(i,j) == 3 || run_fmt(i,j) == 4 || run_fmt(i,j) == 5;
				dirfiles_full_1 = dir([char(bfn_full_1{i,j}),'*bmp']);
				k=0;
				for k=1:size(dirfiles_full_1,1);
					dirfiles_fns_1{i,j}{k} = cellstr(dirfiles_full_1(k).name);
					% 191202: originally, the pics are presented in the
					% opposite direction. I rotated them and do circular
					% shift to accomodate to our current practice
					brl_img = imread(char(strcat(bfn_full_1{i,j},(dirfiles_fns_1{i,j}{k}))));
					brl_img = circshift(brl_img, -13, 2);
					tactim{i,j}{k} = brl_img;
				end

				tim_probe(i,j) = size(tactim{i,j},2)+1;
				brl_img = imread(char(bfn_full_2{i,j}));
				brl_img = circshift(brl_img, -13, 2);
				tactim{i,j}{tim_probe(i,j)} = brl_img;

				timb(i,j) = size(tactim{i,j},2)+1; %blank tactile image
				tactim{i,j}{timb(i,j)} = ones(32,48); %make blank tactile image

				nevents(i,j) = size(dirfiles_full_1,1);

			end
		end
	end
end



ct=0;
%% WAIT FOR TRIGGER
fprintf ('Send trigger\n')
% cedrusopen
% cedrus.resettimer();
% cedrus.close()
cedrusopen
while true
        % the most effective way to clear existing event seems to be to
        % close and to reopen the cedrus
        cedrus.event = [];
        is_trigger = cedrus.waitpress();
        disp(is_trigger)
        if is_trigger==trigger
            break
        end
end
disp 'I''m triggered. No, that''s a good thing!';
ts_trigger(run) = GetSecs;
% 200102: add all the lines related to "theoretical_elapsed" and "real_elapsed"
% to account for the heterogeneity of the timing
theoretical_elapsed = 0;
real_elapsed = 0;

%% CREATE THE TABLE (STRUCT) TO STORE DATA
% trial number
output_data.trial = {};

% type of the trial
output_data.trial_type = {};

% response (button pressed)
output_data.response = {};

% correct answer
output_data.correct = {};

% ... just RT
output_data.rt = {};

% onset of rest (if run_fmt is 0)
output_data.onset_rest = {};

% onset of cue ('listen' or 'touch')
output_data.onset_cue = {};

% onset of stimuli 1
output_data.onset_stim1 = {};

% onset of interval between stim1 and beep
output_data.onset_inter = {};

% onset of beep
output_data.onset_beep = {};

% onset of stimuli 2 (prompt)
output_data.onset_stim2 = {};

% offset of stimuli 2
output_data.offset_stim2 = {};

% onset of response
output_data.onset_response = {};

% offset of response
output_data.offset_response = {};

% when the trigger arrived (to compute the actual duration, I guess?)
output_data.ts_trigger = {};

% onset of the trial
output_data.onset_trial = {};

% offset of the trial
output_data.offset_trial = {};

% the stim file(s) used in this trial
output_data.stim_fn = {};

% the prompt file used in this trial
output_data.prompt_fn = {};

%% EXECUTE EVENTS

FlushEvents('keyDown');
keyIsDown = 0; 
takebreak = 0;
cntr_a=((run-1)*8); %not adding one here because it is added later
dtc = 0;
ct=0;
ct_idx=0;
for ct=1:ttrls; % should be 1:ttrls
	ts_tstart(ct) = GetSecs; %ts for entire trial
	if run_fmt(run,ct) == 3 || run_fmt(run,ct) == 4 || run_fmt(run,ct) == 5
		%Initialize braille display
		port = serial("COM3", 'BaudRate', 38400, 'DataBits', 8, 'StopBits', 1, 'Parity', 'none', 'FlowControl', 'none', 'ByteOrder', 'bigEndian');
		if strcmp(port.Status, 'closed')
			fopen(port);
		end
		size_brl_array = size(tactim{run,ct});
		nbrl = size_brl_array(2);
		if nbrl~=8
			disp('!!!STOP STOP STOP STOP!!!')
			disp('The number of BRL words is incorrect!!!')
		end
		datasize = nbrl*48*32/8;
		s1 = mod(datasize, 256);
		s2 = floor(datasize/256);
		% initialize: set seed
		fwrite(port, [255, 255, 165, 0, 2, 0, 0, 52], 'uint8');
		% initialize: send device data
		fwrite(port, [255, 255, 166, 0, 2, 0, 5, 0], 'uint8');
		pause(0.5)

		fwrite(port, [255, 255, 172, nbrl, s1, s2], 'uint8');
		for brl_item = 1:nbrl
			fwrite(port, encodePicture(tactim{run,ct}{brl_item}), 'uint8');
		end

		%Play Blank
		disp_pic(port, nbrl, dur_bd_blank, nbrl)
        wait_start = GetSecs;
        while (GetSecs-wait_start) < (dur_blank+dur_bdbuf)
        end
		%End Blank
	end

	if run_fmt(run,ct) == 0; %Rest 
		ts_rest(ct) = GetSecs;

		if ct==rest_idxs(end);
			dur_rest = 16-(.15*2);
		else
			dur_rest = 16;
		end

		dtc = dtc + 1;
		if ct == rest_idxs(1);
			dur_tuck(dtc) = sum((ts_tend(1:ct-1)-ts_tstart(1:ct-1))-dur_trial); 
		else
			dur_tuck(dtc) = sum((ts_tend(rest_idxs(find(rest_idxs(:)==ct)-1)+1:ct-1)-ts_tstart(rest_idxs(find(rest_idxs(:)==ct)-1)+1:ct-1))-dur_trial); 
		end

		ts_cue(ct) = nan;
		ts_stim1(ct) = nan;
		ts_stim2(ct) = nan;
		ts_int(ct) = nan;
		ts_beep(ct) = nan;
		ts_respstart(ct) = nan;
		ts_respend(ct) = nan;
		ts_stim2end(ct) = nan;
		ene(ct) = 0; %equiv non equiv
		resp(ct) = 0;
		rt(ct) = 0;
		cor(ct) = nan;

		RestrictKeysForKbCheck(20); %q
		keyIsDown = 0;
		done=false;
		resttimer = 0;
		dur_rest_tucked(dtc) = dur_rest - (real_elapsed - theoretical_elapsed);
		fprintf('Rest for %.2f\n',dur_rest_tucked(dtc));
        % 200102: a temporary change, should figure out how to dynamically
		% adjust the length of rest trials

		breaktimer_start = GetSecs;
		while done==false;
			[keyIsDown, secs, keycode] = KbCheck();
			if GetSecs-breaktimer_start >= dur_rest_tucked(dtc);
				done=true;
			elseif find(keycode)==20 %q
				takebreak = 1;
				break
			end
		end
		   
		if takebreak == 1;
			break
		end

	else %Anything else
		ct_idx=ct_idx+1;

		RestrictKeysForKbCheck(20); %q
		keyIsDown = 0;

		ts_rest(ct) = nan;

		if run_fmt(run,ct) == 1 || run_fmt(run,ct) == 2; %Auditory
			cntr_a=cntr_a+1;

			%Play cue
			ts_cue(ct) = GetSecs;
			PsychPortAudio('Start', hndle_listen,1); 
            wait_start = GetSecs;
            while (GetSecs-wait_start) < dlisten
            end

			%Play word list or backwards speech
			ts_stim1(ct) = GetSecs;
			g=0;
			t8d=0;
			for g=1:nevents(run,ct);
				t8=GetSecs;

				play(afn_audio_1.(strcat('x_',num2str(cntr_a))),floor(aud_timing_samp{cntr_a}(g,1)));
				wait_start = GetSecs;
                dur_wait = aud_timing_sec{cntr_a}(g,3)+dur_audpad;
                while (GetSecs-wait_start)<dur_wait
                end
				stop(afn_audio_1.(strcat('x_',num2str(cntr_a))));
				if g==nevents(run,ct);
				else
					t8d=GetSecs-t8-(aud_timing_sec{cntr_a}(g,3));
                    wait_start = GetSecs;
                    dur_wait = (aud_timing_pause_sec{cntr_a})-t8d;
                    while (GetSecs-wait_start)<dur_wait
                    end
				end
			end

			%Interval
			ts_int(ct) = GetSecs;

			%Play beep
			ts_beep(ct) = GetSecs;
			PsychPortAudio('Start', hndle_beep_low,1); 
			done=false;
			breaktimer_start = GetSecs;
			while done==false;
				[keyIsDown, secs, keycode] = KbCheck();
				if GetSecs-breaktimer_start >= (dur_beep);
					done=true;
				elseif find(keycode)==20 %q
					takebreak = 1;
					break
				end
            end
            wait_start = GetSecs;
            while (GetSecs-wait_start)<dur_int
            end
            
			%Cedrus responses_start
			%Play probe
			ts_stim2(ct)=GetSecs;
			cedrus.getpress; % 200105
			ts_respstart(ct) = GetSecs; % 200105
            PsychPortAudio('Start', hndle_audio_2.(strcat('x_',num2str(cntr_a))),1);
    		
            ts_stim2end(ct) = GetSecs+dur_audio_2.(strcat('x_',num2str(cntr_a)));
			txt = sprintf("ts_stim2end: %f", ts_stim2end(ct));
            
            dur_stim2 = dur_audio_2.(strcat('x_',num2str(cntr_a)));
            wait_start = GetSecs;
            while GetSecs - wait_start < dur_stim2
            end
			stop(afn_audio_2.(strcat('x_',num2str(cntr_a))));
        else %Braille

			%Play cue
			ts_cue(ct) = GetSecs;
			PsychPortAudio('Start', hndle_touch,1); 
            wait_start = GetSecs;
            while (GetSecs-wait_start)<dtouch
            end
            
			%Play braille stimuli
			ts_stim1(ct) = GetSecs;
			i=0;

			if nbrl~=8
				disp('!!!STOP STOP STOP STOP!!!')
				disp('The number of BRL words is incorrect!!!')
			end
			for i=1:nbrl-2
				%Play Stim
				sss = sprintf('Word %d of run %d trial %d', i, run, ct);
				disp(sss)
				disp_pic(port, i, dur_bd_bstim1, nbrl)
                wait_start = GetSecs;
                while (GetSecs-wait_start) < (dur_bstim1+dur_bdbuf)
                end
				%Play Blank

				disp_pic(port, nbrl, dur_bd_blank, nbrl)
				wait_start = GetSecs;
                while (GetSecs-wait_start) < (dur_blank+dur_bdbuf)
                end
			end

			%Interval
			ts_int(ct) = GetSecs;

			%Play beep
			ts_beep(ct) = GetSecs;
			PsychPortAudio('Start', hndle_beep_low,1); 

            wait_start = GetSecs;
            while (GetSecs-wait_start) < dur_int
            end

			%Cedrus responses_start
            
			%Play braille probe
			ts_stim2(ct) = GetSecs;
            disp('The BRL probe')
			disp_pic(port, nbrl-1, dur_bd_bprobe, nbrl)
			
            cedrus.getpress; % 200105
			ts_respstart(ct) = GetSecs; % 200105
		
            wait_start = GetSecs;
            while GetSecs-wait_start < dur_bprobe+dur_bdbuf
            end

			%Play Blank
			disp_pic(port, nbrl, dur_bd_blank, nbrl) 
            wait_start = GetSecs;
            while GetSecs-wait_start < dur_blank+dur_bdbuf
            end
			   
			ts_stim2end(ct) = GetSecs;
			%End braille probe
			% remember to close COM3 port after each trial!!
			fclose(port)
			delete(port)
		end

		%Response period
		while GetSecs - ts_respstart(ct)<dur_resp % 200105
		end
        rt(ct) = GetSecs - ts_respstart(ct);
        resp(ct) = 0;
        if isempty(cedrus.event)==0;
            if isempty(find(cedrus.event(:,4)>ts_respstart(ct)))==0;
                resp(ct)=cedrus.event(find(cedrus.event(:,4)>ts_respstart(ct),1),1);
                rt(ct)=cedrus.event(find(cedrus.event(:,4)>ts_respstart(ct),1),4)-ts_respstart(ct);
            end
        end

		ene(ct) = mc_ary(run,ct_idx);

		ts_respend(ct) = GetSecs;

		if resp(ct)==ene(ct);
			cor(ct)=1;
		elseif isnan(resp(ct));
			cor(ct) = 99;
		else
			cor(ct)=0;
		end

	end

	if takebreak == 1;
	   break
	end

	ts_tend(ct) = GetSecs; %ts for entire trial


	output_data.trial{ct}=ct;
	run_type = '';
	switch run_fmt(run,ct)
		case 0
			run_type = 'rest';
			theoretical_elapsed = theoretical_elapsed + dur_rest;
		case 1
			run_type = 'audio_word';
			theoretical_elapsed = theoretical_elapsed + dur_aud_trial_empirical;
		case 2
			run_type = 'audio_nonsense';
			theoretical_elapsed = theoretical_elapsed + dur_aud_trial_empirical;
		case 3
			run_type = 'brl_word';
			theoretical_elapsed = theoretical_elapsed + dur_brl_trial_empirical;
		case 4
			run_type = 'brl_consonant';
			theoretical_elapsed = theoretical_elapsed + dur_brl_trial_empirical;
		case 5
			run_type = 'brl_shape';
			theoretical_elapsed = theoretical_elapsed + dur_brl_trial_empirical;
	end
	output_data.trial_type{ct} = run_type;
	% response (button pressed)
	output_data.response{ct} = resp(ct);
	% correct answer
	is_correct = (ene(ct)==resp(ct));
	output_data.correct{ct} = is_correct+0;
	% ... just RT
	output_data.rt{ct} = rt(ct);

	txt = sprintf('Trial: %d, type: %s, answer: %d, correct: %d, rt: %.4f\n', ct, run_type, resp(ct), is_correct, rt(ct));
	disp(txt)

	% onset of rest (if run_fmt is 0)
	output_data.onset_rest{ct} = ts_rest(ct) - ts_trigger(run);

    % onset of cue ('listen' or 'touch')
	output_data.onset_cue{ct} = ts_cue(ct) - ts_trigger(run);

    % onset of stimuli 1
	output_data.onset_stim1{ct} = ts_stim1(ct) - ts_trigger(run);

    % onset of interval between stim1 and beep
	output_data.onset_inter{ct} = ts_int(ct) - ts_trigger(run);

    % onset of beep
	output_data.onset_beep{ct} = ts_beep(ct) - ts_trigger(run);

    % onset of stimuli 2 (prompt)
	output_data.onset_stim2{ct} = ts_stim2(ct) - ts_trigger(run);

    % offset of stimuli 2
	output_data.offset_stim2{ct} = ts_stim2end(ct) - ts_trigger(run);

    % onset of response
	output_data.onset_response{ct} = ts_respstart(ct) - ts_trigger(run);

    % offset of response
	output_data.offset_response{ct} = ts_respend(ct) - ts_trigger(run);

    % when the trigger arrived (to compute the actual duration, I guess?)
	output_data.ts_trigger{ct} = ts_trigger(run);

    % onset of the trial
	output_data.onset_trial{ct} = ts_tstart(ct) - ts_trigger(run);

    % offset of the trial
	output_data.offset_trial{ct} = ts_tend(ct) - ts_trigger(run);

	real_elapsed = real_elapsed + (ts_tend(ct)-ts_tstart(ct));

	switch run_fmt(run,ct)
		case 1
			stim_file = afn_full_1{run,ct};
			prompt_file = afn_full_2{run,ct};
		case 2
			stim_file = afn_full_1{run,ct};
			prompt_file = afn_full_2{run,ct};
		otherwise
			stim_file = bfn_full_1{run,ct};
			prompt_file = bfn_full_2{run,ct};
	end

	if run_fmt(run,ct)~=0
		stim_file = split(stim_file, '/Group');
		stim_file = strcat('Group', stim_file{2});
		output_data.stim_fn{ct} = stim_file;

		prompt_file = split(prompt_file, '/Group');
		prompt_file = strcat('Group', prompt_file{2});
		output_data.prompt_fn{ct} = prompt_file;
	else
		output_data.stim_fn{ct} = 'rest';
		output_data.prompt_fn{ct} = 'rest';
	end

	if run_fmt(run,ct)==0
		fn = fieldnames(output_data);
		for jj=1:numel(fn)
			df.(fn{jj}) = (output_data.(fn{jj}))';
		end
		df_table = struct2table(df);
		writetable(df_table, fn_data_xls)
	end
end

if takebreak==1;
	fprintf('Quit run %d\n',run)

	if exist('cedrus')==1
		cedrus.close();
	end
	if exist('output_data')==1
		dlmcell(fn_data,output_data);
	end
	PsychPortAudio('Stop', hndle_beep_low,1);
	PsychPortAudio('Stop',hndle_cs.(strcat('x',num2str(ct_idx))),1);
	PsychPortAudio('Stop', hndle_ccom.(strcat('x',num2str(ct_idx))),1);
else %feedback only if run completed
	fprintf ('End of run %d\n',run)
	fn = fieldnames(output_data);
	for jj=1:numel(fn)
		output_data.(fn{jj}) = (output_data.(fn{jj}))';
	end
	df_table = struct2table(output_data);
	writetable(df_table, fn_data_xls)

	cedrus.close();
	percor(run) = (length(find(cor==1))/size(cos,2))*100;

	fprintf ('%.2f%% Correct \n', percor(run));
end

clearvars output_data
