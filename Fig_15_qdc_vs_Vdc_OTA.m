clc
close all
clear all
plt=0;

cd 'E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-11dbm_1m'
listing = dir("**");
tbl = struct2table(listing);
tbl.date = datetime(tbl.datenum,ConvertFrom="datenum");
tbl = removevars(tbl,"datenum");
folders = tbl(tbl.isdir,:);
namedFolders = folders(~matches(folders.name,[".",".."]),:);
folder_1=table2array(namedFolders(:,1));
folder_2=table2array(namedFolders(:,2));
folder_3=strcat(folder_2,'\',folder_1);
folder_3=convertCharsToStrings(folder_3);

val_current=folder_3(1);
val_data_bits=folder_3(2);
val_vrad=folder_3(3);

%val_data_bits=string(py.str(val_data_bits));
P_bits = fullfile(val_data_bits);
S_bits = dir(fullfile(P_bits,'*.mat')); 
for K_bits = 1:numel(S_bits)
    F_bits = fullfile(P_bits,S_bits(K_bits).name);
    S_bits(K_bits).data = load(F_bits);
end

Bits=S_bits(1).data;
%Bits=load('C:\Users\mpmayeka\Desktop\DATA\20251205\measurements\dpo\N5_1010__-17dbm_1m\SLICED_Inv_data_bits\SLICED_20251205-181959_dpo_LTI_ook_fc_2.713000e+07_dam_N_5_phi_90_mode_1010_20dB_dc_1.2v_adg919_vdc_est.mat');
Bits.yrf=round(Bits.yrf);
time_stamp=[];
time_stamp_index=0;
time_stamp_locs=0;
for i=2:length(Bits.yrf)-1
time_diff=abs(Bits.yrf(1,i)-Bits.yrf(1,i-1));
if time_diff == 1
    time_stamp_index=time_stamp_index+1;
time_stamp(time_stamp_index)=Bits.trf(1,i-1);
time_stamp_locs(time_stamp_index)=i-1;
end
end
median_time_stamp_locs=[];
median_time_stamp_index=0;
for i=1:2:length(time_stamp_locs)
median_time_stamp_index=median_time_stamp_index+1;
median_time_stamp_locs(median_time_stamp_index)=time_stamp_locs(i)+floor((time_stamp_locs(i+1)-time_stamp_locs(i))/2);
end

median_time_stamp_index=0;
I_error_locs=[];
for i=1:2:length(time_stamp_locs)
  median_time_stamp_index=median_time_stamp_index+1;
  I_error_locs(1,i)=median_time_stamp_locs(median_time_stamp_index);
  I_error_locs(1,i+1)=time_stamp_locs(i+1);
end

if plt==1
plot(Bits.trf,Bits.yrf,Bits.trf(time_stamp_locs),Bits.yrf(time_stamp_locs),'o','LineWidth',1.5) %fig 1
end

% hold on
% plot(Bits.trf,masked_data_min_current,time_stamp_locs,Bits.yrf(time_stamp_locs),'o')

% val_current=cell(val_current);
% P = fullfile(string(py.str(val_current{1,1})));
P = fullfile(val_current);
S = dir(fullfile(P,'*.mat')); 
for K = 1:numel(S)
    F = fullfile(P,S(K).name);
    S(K).data = load(F);
end

for o=1:K
DC_DAM_vdc_min_current=S(o).data; %load('C:\Users\mpmayeka\Desktop\20240518_w_I_prbs_2sw\measurements\dpo\SLICED_CURRENT\SLICED_20240518-211013_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_prbs_10dB_dc_1.4v_adg919_v16.mat');

DC_DAM_vdc_min_current.yrf=interp1(DC_DAM_vdc_min_current.trf,DC_DAM_vdc_min_current.yrf,Bits.trf,'spline');

if plt==1
figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(time_stamp_locs),DC_DAM_vdc_min_current.yrf(time_stamp_locs),'o','LineWidth',1.5) %fig 2
hold on
plot(Bits.trf(median_time_stamp_locs),DC_DAM_vdc_min_current.yrf(median_time_stamp_locs),'*','LineWidth',1.5) %fig 2

figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(I_error_locs),DC_DAM_vdc_min_current.yrf(I_error_locs),'o','LineWidth',1.5) %fig 3
hold on
end

I_error=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
I_error(I_error_index)=sum(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))/length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)));
if plt==1
plot(Bits.trf(1,I_error_locs(i):I_error_locs(i+1)),repelem(I_error(I_error_index),length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))),'Color','g','LineWidth',1.5) %fig 3
end
end

I_error_index=0;
DC_DAM_vdc_min_current_corrected=[];
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
DC_DAM_vdc_min_current_corrected{I_error_index}=DC_DAM_vdc_min_current.yrf(1,time_stamp_locs(i):time_stamp_locs(i+1))-I_error(I_error_index);
if plt==1
plot(Bits.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),DC_DAM_vdc_min_current_corrected{I_error_index}) %fig 3
end
end

I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    [pks,locs] =findpeaks(DC_DAM_vdc_min_current_corrected{I_error_index},Bits.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',1e-3);
    pks_min_current(I_error_index,1)=pks(1,1);
    locs_min_current(I_error_index,1)=locs(1,1);
    [pks_inv,locs_inv] =findpeaks(-1.*DC_DAM_vdc_min_current_corrected{I_error_index},Bits.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',1e-3,'MinPeakWidth',3e-9); %MinPeakProminence',3.2e-3
    pks_min_current(I_error_index,2)=-1*pks_inv(1,1);
    locs_min_current(I_error_index,2)=locs_inv(1,1);
    if plt==1
    plot(locs_min_current(I_error_index,:),pks_min_current(I_error_index,:),'*') %fig 3
    end
end

pks_locs=[];
for i=1:length(I_error)
   for j=1:2
pks_locs(i,j)=find(Bits.trf==locs_min_current(i,j));
   end
end

masked_data_min_current=Bits.yrf.*DC_DAM_vdc_min_current.yrf;
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
masked_data_min_current(1,time_stamp_locs(i):time_stamp_locs(i+1))=DC_DAM_vdc_min_current_corrected{I_error_index};
end


loop_break=0;
start_time_stamp_locs=[];
for i=1:length(I_error)
    for j=pks_locs(i,1):pks_locs(i,2)
        if (masked_data_min_current(j) <= 0) && (loop_break == 0)
            loop_break=1; 
            start_time_stamp_locs(1,i)=j;
        end
    end
    if loop_break == 0 
            start_time_stamp_locs(1,i)=pks_locs(i,2);
    end
   loop_break=0; 
end

I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
   masked_data_min_current(1,time_stamp_locs(1,i):start_time_stamp_locs(1,I_error_index))=0;
end
if plt==1
figure
plot(Bits.trf,masked_data_min_current) %fig 4
   hold on
end

final_time_stamp_locs=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
final_time_stamp_locs(1,i)=start_time_stamp_locs(1,I_error_index);
final_time_stamp_locs(1,i+1)=start_time_stamp_locs(1,I_error_index)+55;     %time_stamp_locs(1,i+1); %-round(3*(time_stamp_locs(1,i+1)-time_stamp_locs(1,i))/4);
end
if plt==1
plot(Bits.trf(final_time_stamp_locs),masked_data_min_current(final_time_stamp_locs),'o') %fig 4
end
Current=masked_data_min_current;
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))=(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))./5;
end
if plt==1
figure
plot(Bits.trf,Current) %fig 5
end

Current_avg=[];
Abs_Current_avg=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Current_avg(1,I_error_index)=(sum((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))))*(Bits.trf(1,2)-Bits.trf(1,1))); %/(Bits.trf(1,final_time_stamp_locs(1,i+1))-Bits.trf(1,final_time_stamp_locs(1,i)));%/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
Abs_Current_avg(1,I_error_index)=(sum(abs(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))))*(Bits.trf(1,2)-Bits.trf(1,1))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
end
if plt==1
figure
plot(Current_avg) %fig 6
end

Current_mean(1,o)=sum(Current_avg)/length(Current_avg);
%Current_mean_abs(1,o)=sum(Abs_Current_avg)/length(Abs_Current_avg);
if plt==1
hold on
plot(repelem(Current_mean(1,o),length(Current_avg))) %fig 6
end
end

if plt==0
Current_mean=[wrev(Current_mean(1,17:31)) Current_mean(1,1:16)];
%Current_mean_abs=[wrev(Current_mean_abs(1,17:31)) Current_mean_abs(1,1:16)];

%lines = readlines(string(py.str(val_current{1,2})),"EmptyLineRule","skip");
folder_2=convertCharsToStrings(folder_2);
% lines = readlines('C:\Users\mpmayeka\Desktop\DATA\20251205\measurements\dpo\N5_1010__-17dbm_1m\DC voltage profile.txt',"EmptyLineRule","skip");
lines = readlines(strcat(folder_2(1),'\','DC voltage profile.txt'));
for i=1:16
k = strfind(lines(i,1),'Voltage= ');
vdc_inc(1,i)=str2double(extractBetween(lines(i,1),k+9,k+9+6));
end
count=0;
for i=17:31
    count=count+1;
k = strfind(lines(i,1),'Voltage= ');
vdc_dec(1,count)=str2double(extractBetween(lines(i,1),k+9,k+9+6)); 
end

vdc=[wrev(vdc_dec) vdc_inc];


% v_dc_inc=[0.9971 1.0459 1.0948 1.1388 1.1828 1.2366 1.2757 1.3196 1.3636 1.4076 1.4418 1.4858 1.5200 1.5543 1.5982 1.6276];
% v_dc_dec=wrev([0.9482 0.8944 0.8407 0.7820 0.7331 0.6745 0.6158 0.5523 0.4888 0.4252 0.3568 0.2933 0.2199 0.1711 0.1711]);
% v_dc=[v_dc_dec v_dc_inc];


figure
% plot(v_dc,Current_mean_abs)
% hold on
% yyaxis right
plot(vdc,Current_mean,'LineWidth',1.5) %/max(Current_mean)
grid on
grid minor
xlabel('$V_{dc} (volts)$','FontSize',20,'FontWeight','bold','Interpreter','latex')
ylabel('$\overline{Q_{dc}}$','FontSize',20,'FontWeight','bold','Interpreter','latex')

%saveas(gcf,strcat(string(py.str(val_current{1,3})),'/Qdc_vs_Vdc.fig'))

%val_vrad=string(py.str(val_vrad));
P_vrad = fullfile(val_vrad);
S_vrad = dir(fullfile(P_vrad,'*.mat')); 
for K_vrad = 1:numel(S_vrad)
    F_vrad = fullfile(P_vrad,S_vrad(K_vrad).name);
    S_vrad(K_vrad).data = load(F_vrad);
end

figure
for i=1:K_vrad
%figure
DC_DAM_vdc_min_Vrad=S_vrad(i).data;
%DC_DAM_vdc_min_Vrad=load('E:\1m monopole antenna DC DAM_inlab_3\20251127\measurements\dpo\N10_prbs__-11dbm_1m\SLICED_Vrad\SLICED_20251127-191741_dpo_LTI_ook_fc_2.713000e+07_dam_N_10_phi_90_mode_prbs_20dB_dc_1.2v_adg919_vdc_est.mat');
plot(DC_DAM_vdc_min_Vrad.trf,DC_DAM_vdc_min_Vrad.yrf)
hold on
end
end


% hold on
% yyaxis right
% plot(Bits.trf,Current,'LineWidth',1.5)










