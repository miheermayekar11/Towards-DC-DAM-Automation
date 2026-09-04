clc
close all
clear all

tiledlayout(2,1,'TileSpacing','tight','Padding','tight')
%ax=axes;
Bits=load('C:\Users\mpmayeka\Desktop\20240522_1010 inverse data bits dso ch 3\measurements\dpo\SLICED\SLICED_20240522-183214_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_1010_10dB_dc_1.4v_adg919.mat');
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

%plot(Bits.trf,Bits.yrf,Bits.trf(time_stamp_locs),Bits.yrf(time_stamp_locs),'o','LineWidth',1.5)

%% hold on
%% plot(Bits.trf,masked_data_min_current,time_stamp_locs,Bits.yrf(time_stamp_locs),'o')

P = fullfile('C:\Users\mpmayeka\Desktop\20240518_w_I_1010_2sw\measurements\dpo\SLICED_CURRENT');
S = dir(fullfile(P,'*.mat')); 
for K = 1:numel(S)
    F = fullfile(P,S(K).name);
    S(K).data = load(F);
end

for o=1:K
DC_DAM_vdc_min_current= S(o).data; %load('C:\Users\mpmayeka\Desktop\20240518_w_I_1010_2sw\measurements\dpo\SLICED_CURRENT\SLICED_20240518-205356_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_1010_10dB_dc_1.4v_adg919_v16.mat');
% figure
% plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(time_stamp_locs),DC_DAM_vdc_min_current.yrf(time_stamp_locs),'o','LineWidth',1.5)
% hold on
% plot(Bits.trf(median_time_stamp_locs),DC_DAM_vdc_min_current.yrf(median_time_stamp_locs),'*','LineWidth',1.5)
% 
% figure
% plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(I_error_locs),DC_DAM_vdc_min_current.yrf(I_error_locs),'o','LineWidth',1.5)
% hold on

I_error=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
I_error(I_error_index)=sum(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))/length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)));
%plot(DC_DAM_vdc_min_current.trf(1,I_error_locs(i):I_error_locs(i+1)),repelem(I_error(I_error_index),length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))),'Color','g','LineWidth',1.5)
end

I_error_index=0;
DC_DAM_vdc_min_current_corrected=[];
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
DC_DAM_vdc_min_current_corrected(I_error_index,:)=DC_DAM_vdc_min_current.yrf(1,time_stamp_locs(i):time_stamp_locs(i+1))-I_error(I_error_index);
%plot(DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),DC_DAM_vdc_min_current_corrected(I_error_index,:))
end

I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    [pks,locs] =findpeaks(DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',1e-3);
    pks_min_current(I_error_index,1)=pks(1,1);
    locs_min_current(I_error_index,1)=locs(1,1);
    [pks_inv,locs_inv] =findpeaks(-1.*DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',1e-3);
    pks_min_current(I_error_index,2)=-1*pks_inv(1,1);
    locs_min_current(I_error_index,2)=locs_inv(1,1);
    %plot(locs_min_current(I_error_index,:),pks_min_current(I_error_index,:),'*')
end

pks_locs=[];
for i=1:length(I_error)
   for j=1:2
pks_locs(i,j)=find(DC_DAM_vdc_min_current.trf==locs_min_current(i,j));
   end
end

masked_data_min_current=Bits.yrf.*DC_DAM_vdc_min_current.yrf;
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
masked_data_min_current(1,time_stamp_locs(i):time_stamp_locs(i+1))=DC_DAM_vdc_min_current_corrected(I_error_index,:);
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
% figure
% plot(DC_DAM_vdc_min_current.trf,masked_data_min_current)
%    hold on

final_time_stamp_locs=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
final_time_stamp_locs(1,i)=start_time_stamp_locs(1,I_error_index);
final_time_stamp_locs(1,i+1)=time_stamp_locs(1,i+1);
end

%plot(DC_DAM_vdc_min_current.trf(final_time_stamp_locs),masked_data_min_current(final_time_stamp_locs),'o')

Current=masked_data_min_current;
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))=(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))./5;
end

% figure
% plot(DC_DAM_vdc_min_current.trf,Current)

Abs_Current_avg=[];
Current_avg=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Abs_Current_avg(1,I_error_index)=(sum(abs(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
        Current_avg(1,I_error_index)=(sum((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
end
% figure
% plot(Abs_Current_avg)
% figure
% plot(Current_avg)

Abs_Current_mean(1,o)=sum(Abs_Current_avg)/length(Abs_Current_avg);
Current_mean(1,o)=sum(Current_avg)/length(Current_avg);
%hold on
%plot(repelem(Abs_Current_mean(1,o),length(Abs_Current_avg)))
%plot(repelem(Current_mean(1,o),length(Current_avg)))
end

Abs_Current_mean=[wrev(Abs_Current_mean(1,17:31)) Abs_Current_mean(1,1) Abs_Current_mean(1,2:16)];
Current_mean=[wrev(Current_mean(1,17:31)) Current_mean(1,1) Current_mean(1,2:16)];

v_dc_inc=[0.9042 0.9531 1.0020 1.0508 1.0948 1.1388 1.1926 1.2366 1.2805 1.3245 1.3685 1.4076 1.4516 1.4907 1.5298 1.5640];
v_dc_dec=wrev([0.8456 0.7918 0.7380 0.6794 0.6207 0.5621 0.4936 0.4301 0.3617 0.2981 0.2248 0.1711 0.1711 0.1711 0.1711]);
v_dc=[v_dc_dec v_dc_inc];

%nexttile
%figure
% plot(v_dc,Abs_Current_mean)
% hold on
% yyaxis right
plot(v_dc,Current_mean,'b','LineWidth',3)
%ax.YAxis.Color = [0 0 1];

grid on
grid minor
%ylim([-4e-11 6e-11])
xlim([0.1711 1])
xlabel('V_{dc} (volts)')
ylabel('q_{dc} (C)','Color','b')
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
xline(0.71,'--b','0.71 v','FontWeight','bold','FontSize',28,'LabelHorizontalAlignment','left','LineWidth',1.5)
yline(0,'--b','LineWidth',1.5)
%ylim([-1.5e-12 1.5e-12])
title('$AEC-1$','FontSize',28,'interpreter','latex')


%%%%% off bit radiation
%%%%% plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
plt=0;
Bits=load('C:\Users\mpmayeka\Desktop\20240522_1010 inverse data bits dso ch 3\measurements\dpo\SLICED\SLICED_20240522-183214_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_1010_10dB_dc_1.4v_adg919.mat');
Bits.yrf=round(Bits.yrf);
time_stamp=[];
time_stamp_index=0;
time_stamp_locs=0;
for i=2:length(Bits.yrf)-1
time_diff=(Bits.yrf(1,i)-Bits.yrf(1,i-1));
if time_diff == 1
    time_stamp_index=time_stamp_index+1;
time_stamp(time_stamp_index)=Bits.trf(1,i-1);
time_stamp_locs(time_stamp_index)=i+10;
end
if time_diff == -1
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
plot(Bits.trf,Bits.yrf,Bits.trf(time_stamp_locs),Bits.yrf(time_stamp_locs),'o','LineWidth',1.5)
end

%% hold on
%% plot(Bits.trf,masked_data_min_current,time_stamp_locs,Bits.yrf(time_stamp_locs),'o')

P = fullfile('C:\Users\mpmayeka\Desktop\20240518_w_I_1010_2sw\measurements\dpo\SLICED_VRAD');
S = dir(fullfile(P,'*.mat')); 
for K = 1:numel(S)
    F = fullfile(P,S(K).name);
    S(K).data = load(F);
end


bit_energy_ideal=[];
for o=1:K
single_bit_ideal=[];
DC_DAM_vdc_min_current= S(o).data; %load('C:\Users\mpmayeka\Desktop\20240518_w_I_1010_2sw\measurements\dpo\SLICED_CURRENT\SLICED_20240518-205356_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_1010_10dB_dc_1.4v_adg919_v16.mat');
single_bit_ideal=DC_DAM_vdc_min_current.yrf(1,5843:6073);
bit_energy_ideal(1,o)=sum(((single_bit_ideal).^2).*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)));

if plt==1
figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(time_stamp_locs),DC_DAM_vdc_min_current.yrf(time_stamp_locs),'o','LineWidth',1.5)
hold on
plot(Bits.trf(median_time_stamp_locs),DC_DAM_vdc_min_current.yrf(median_time_stamp_locs),'*','LineWidth',1.5)

figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(I_error_locs),DC_DAM_vdc_min_current.yrf(I_error_locs),'o','LineWidth',1.5)
hold on
end

I_error=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
I_error(I_error_index)=sum(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))/length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)));

if plt==1
plot(DC_DAM_vdc_min_current.trf(1,I_error_locs(i):I_error_locs(i+1)),repelem(I_error(I_error_index),length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))),'Color','g','LineWidth',1.5)
end

end

I_error_index=0;
DC_DAM_vdc_min_current_corrected=[];
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
DC_DAM_vdc_min_current_corrected(I_error_index,:)=DC_DAM_vdc_min_current.yrf(1,time_stamp_locs(i):time_stamp_locs(i+1))-I_error(I_error_index);

if plt==1
plot(DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),DC_DAM_vdc_min_current_corrected(I_error_index,:))
end

end

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%     [pks,locs] =findpeaks(DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',6e-3);
%     pks_min_current(I_error_index,1)=pks(1,2);
%     locs_min_current(I_error_index,1)=locs(1,2);
%     [pks_inv,locs_inv] =findpeaks(-1.*DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',6e-3);
%     pks_min_current(I_error_index,2)=-1*pks_inv(1,2);
%     locs_min_current(I_error_index,2)=locs_inv(1,2);
% 
%     if plt==1
%     plot(locs_min_current(I_error_index,:),pks_min_current(I_error_index,:),'*')
%     end
% end
% 
% pks_locs=[];
% for i=1:length(I_error)
%    for j=1:2
% pks_locs(i,j)=find(DC_DAM_vdc_min_current.trf==locs_min_current(i,j));
%    end
% end
% 
masked_data_min_current=Bits.yrf.*DC_DAM_vdc_min_current.yrf;
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
masked_data_min_current(1,time_stamp_locs(i):time_stamp_locs(i+1))=DC_DAM_vdc_min_current_corrected(I_error_index,:);
end
% 
% 
% loop_break=0;
% start_time_stamp_locs=[];
% for i=1:length(I_error)
%     for j=pks_locs(i,1):pks_locs(i,2)
%         if (masked_data_min_current(j) >= 0) && (loop_break == 0)
%             loop_break=1; 
%             start_time_stamp_locs(1,i)=j;
%         end
%     end
%     if loop_break == 0 
%             start_time_stamp_locs(1,i)=pks_locs(i,2);
%     end
%    loop_break=0; 
% end
% 
% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%    masked_data_min_current(1,time_stamp_locs(1,i):start_time_stamp_locs(1,I_error_index))=0;
% end
% 
% if plt==1
% figure
% plot(DC_DAM_vdc_min_current.trf,masked_data_min_current)
%    hold on
% end

final_time_stamp_locs=time_stamp_locs;

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
% final_time_stamp_locs(1,i)=start_time_stamp_locs(1,I_error_index);
% final_time_stamp_locs(1,i+1)=time_stamp_locs(1,i+1);
% end

if plt==1
plot(DC_DAM_vdc_min_current.trf(final_time_stamp_locs),masked_data_min_current(final_time_stamp_locs),'o')
end

Current=masked_data_min_current;

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%     Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))=(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))./5;
% end

if plt==1
figure
plot(DC_DAM_vdc_min_current.trf,Current)
end

Abs_Current_avg=[];
Current_avg=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Abs_Current_avg(1,I_error_index)=(sum(((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))).^2)*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
        Current_avg(1,I_error_index)=abs(sum((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))))*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
end

if plt==1
% figure
% plot(Abs_Current_avg)
figure
plot(Current_avg)
end

Abs_Current_mean(1,o)=sum(Abs_Current_avg)/length(Abs_Current_avg);
Current_mean(1,o)=sum(Current_avg)/length(Current_avg);

if plt==1
hold on
% plot(repelem(Abs_Current_mean(1,o),length(Abs_Current_avg)))
plot(repelem(Current_mean(1,o),length(Current_avg)))
end
end

Abs_Current_mean=[wrev(Abs_Current_mean(1,17:31)) Abs_Current_mean(1,1) Abs_Current_mean(1,2:16)];
Current_mean=[wrev(Current_mean(1,17:31)) Current_mean(1,1) Current_mean(1,2:16)];

Eb_off_by_Eb_ss=Abs_Current_mean./[wrev(bit_energy_ideal(1,17:31)) bit_energy_ideal(1,1:16)];

v_dc_inc=[0.9042 0.9531 1.0020 1.0508 1.0948 1.1388 1.1926 1.2366 1.2805 1.3245 1.3685 1.4076 1.4516 1.4907 1.5298 1.5640];
v_dc_dec=wrev([0.8456 0.7918 0.7380 0.6794 0.6207 0.5621 0.4936 0.4301 0.3617 0.2981 0.2248 0.1711 0.1711 0.1711 0.1711]);
v_dc=[v_dc_dec v_dc_inc];



hold on
% plot(v_dc,Abs_Current_mean)
hold on
yyaxis right
plot(v_dc,Eb_off_by_Eb_ss,'r','LineWidth',3)
ylabel('E_{b-off}/E_{b-ss}','Color','r')
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
%xlim([0.4301 0.86])
xline(0.43,'--r','0.43 v','FontWeight','bold','FontSize',28,'LabelHorizontalAlignment','left','LineWidth',1.5)
yline(0.0177,'--r','LineWidth',1.5)
%ax.YAxis.Color = [1 0 0];
%ax.YAxis(2).Color = [1 0 0];

%%%%%%%%%%%%%%%%%%%%%%%% antenna qdc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

plt=0;

Bits=load('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\SLICED_Inv_data_bits\SLICED_20251216-130657_dpo_LTI_ook_fc_2.800000e+07_dam_N_10_phi_90_mode_prbs_20dB_dc_1.2v_adg919_vdc_est.mat');
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


P = fullfile('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\SLICED_Current');
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

lines = readlines('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\DC voltage profile.txt',"EmptyLineRule","skip");

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

%nexttile
figure
% plot(v_dc,Current_mean_abs)
% hold on
% yyaxis right
plot(vdc,Current_mean,'b','LineWidth',3) %/max(Current_mean)

grid on
grid minor
%ylim([-4e-11 6e-11])
%xlim([0.1711 1])
xlabel('V_{dc} (volts)')
ylabel('q_{dc} (C)','Color','b')
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
xline(0.45,'--b','0.45 v','FontWeight','bold','FontSize',28,'LabelHorizontalAlignment','left','LineWidth',1.5)
yline(0,'--b','LineWidth',1.5)
%ylim([-1.5e-12 1.5e-12])
end
title('$\lambda/10 - ESA$','FontSize',28,'interpreter','latex')

%%%%%%%%%%%%%%%%%%%%%%%%%%%% antenna offbit energy %%%%%%%%%%%%%%%%%%%%%%%

clear all

plt=0;
Bits=load('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\SLICED_Inv_data_bits\SLICED_20251216-130657_dpo_LTI_ook_fc_2.800000e+07_dam_N_10_phi_90_mode_prbs_20dB_dc_1.2v_adg919_vdc_est.mat');
Bits.yrf=round(Bits.yrf);
time_stamp=[];
time_stamp_index=0;
time_stamp_locs=0;
for i=2:length(Bits.yrf)-1
time_diff=(Bits.yrf(1,i)-Bits.yrf(1,i-1));
if time_diff == 1
    time_stamp_index=time_stamp_index+1;
time_stamp(time_stamp_index)=Bits.trf(1,i-1);
time_stamp_locs(time_stamp_index)=i+10;
end
if time_diff == -1
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
plot(Bits.trf,Bits.yrf,Bits.trf(time_stamp_locs),Bits.yrf(time_stamp_locs),'o','LineWidth',1.5)
end

%% hold on
%% plot(Bits.trf,masked_data_min_current,time_stamp_locs,Bits.yrf(time_stamp_locs),'o')

P = fullfile('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\SLICED_Vrad');
S = dir(fullfile(P,'*.mat')); 
for K = 1:numel(S)
    F = fullfile(P,S(K).name);
    S(K).data = load(F);
end

bit_energy_ideal=[];

for o=1:K
single_bit_ideal=[];    
DC_DAM_vdc_min_current= S(o).data; %load('C:\Users\mpmayeka\Desktop\20240518_w_I_1010_2sw\measurements\dpo\SLICED_CURRENT\SLICED_20240518-205356_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_1010_10dB_dc_1.4v_adg919_v16.mat');
DC_DAM_vdc_min_current.yrf=interp1(DC_DAM_vdc_min_current.trf,DC_DAM_vdc_min_current.yrf,Bits.trf,'spline');
fs=1/(DC_DAM_vdc_min_current.trf(2)-DC_DAM_vdc_min_current.trf(1));
DC_DAM_vdc_min_current.yrf=lowpass(DC_DAM_vdc_min_current.yrf,30e6,fs);
single_bit_ideal=DC_DAM_vdc_min_current.yrf(1,6694:6960);
bit_energy_ideal(1,o)=sum(((single_bit_ideal).^2).*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)));
if plt==1
figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(time_stamp_locs),DC_DAM_vdc_min_current.yrf(time_stamp_locs),'o','LineWidth',1.5)
hold on
plot(Bits.trf(median_time_stamp_locs),DC_DAM_vdc_min_current.yrf(median_time_stamp_locs),'*','LineWidth',1.5)

figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(I_error_locs),DC_DAM_vdc_min_current.yrf(I_error_locs),'o','LineWidth',1.5)
hold on
end

I_error=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
I_error(I_error_index)=sum(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))/length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)));

if plt==1
plot(DC_DAM_vdc_min_current.trf(1,I_error_locs(i):I_error_locs(i+1)),repelem(I_error(I_error_index),length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))),'Color','g','LineWidth',1.5)
end

end

I_error_index=0;
DC_DAM_vdc_min_current_corrected=[];
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
DC_DAM_vdc_min_current_corrected{I_error_index}=DC_DAM_vdc_min_current.yrf(1,time_stamp_locs(i):time_stamp_locs(i+1))-I_error(I_error_index);

if plt==1
plot(DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),DC_DAM_vdc_min_current_corrected{I_error_index})
end

end

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%     [pks,locs] =findpeaks(DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',6e-3);
%     pks_min_current(I_error_index,1)=pks(1,2);
%     locs_min_current(I_error_index,1)=locs(1,2);
%     [pks_inv,locs_inv] =findpeaks(-1.*DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',6e-3);
%     pks_min_current(I_error_index,2)=-1*pks_inv(1,2);
%     locs_min_current(I_error_index,2)=locs_inv(1,2);
% 
%     if plt==1
%     plot(locs_min_current(I_error_index,:),pks_min_current(I_error_index,:),'*')
%     end
% end
% 
% pks_locs=[];
% for i=1:length(I_error)
%    for j=1:2
% pks_locs(i,j)=find(DC_DAM_vdc_min_current.trf==locs_min_current(i,j));
%    end
% end
% 
masked_data_min_current=Bits.yrf.*DC_DAM_vdc_min_current.yrf;
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
masked_data_min_current(1,time_stamp_locs(i):time_stamp_locs(i+1))=DC_DAM_vdc_min_current_corrected{I_error_index};
end
% 
% 
% loop_break=0;
% start_time_stamp_locs=[];
% for i=1:length(I_error)
%     for j=pks_locs(i,1):pks_locs(i,2)
%         if (masked_data_min_current(j) >= 0) && (loop_break == 0)
%             loop_break=1; 
%             start_time_stamp_locs(1,i)=j;
%         end
%     end
%     if loop_break == 0 
%             start_time_stamp_locs(1,i)=pks_locs(i,2);
%     end
%    loop_break=0; 
% end
% 
% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%    masked_data_min_current(1,time_stamp_locs(1,i):start_time_stamp_locs(1,I_error_index))=0;
% end
% 
% if plt==1
% figure
% plot(DC_DAM_vdc_min_current.trf,masked_data_min_current)
%    hold on
% end

final_time_stamp_locs=time_stamp_locs;

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
% final_time_stamp_locs(1,i)=start_time_stamp_locs(1,I_error_index);
% final_time_stamp_locs(1,i+1)=time_stamp_locs(1,i+1);
% end

if plt==1
plot(DC_DAM_vdc_min_current.trf(final_time_stamp_locs),masked_data_min_current(final_time_stamp_locs),'o')
end

Current=masked_data_min_current;

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%     Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))=(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))./5;
% end

if plt==1
figure
plot(DC_DAM_vdc_min_current.trf,Current)
end

Abs_Current_avg=[];
Current_avg=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Abs_Current_avg(1,I_error_index)=(sum(((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))).^2)*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
        Current_avg(1,I_error_index)=abs(sum((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))))*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
end

if plt==1
% figure
% plot(Abs_Current_avg)
figure
plot(Current_avg)
end

Abs_Current_mean(1,o)=sum(Abs_Current_avg)/length(Abs_Current_avg);
Current_mean(1,o)=sum(Current_avg)/length(Current_avg);

if plt==1
hold on
% plot(repelem(Abs_Current_mean(1,o),length(Abs_Current_avg)))
plot(repelem(Current_mean(1,o),length(Current_avg)))
end
end

if plt==0
Abs_Current_mean=[wrev(Abs_Current_mean(1,17:31)) Abs_Current_mean(1,1) Abs_Current_mean(1,2:16)];
Current_mean=[wrev(Current_mean(1,17:31)) Current_mean(1,1) Current_mean(1,2:16)];

Eb_off_by_Eb_ss=Abs_Current_mean./[wrev(bit_energy_ideal(1,17:31)) bit_energy_ideal(1,1:16)];

lines = readlines('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\DC voltage profile.txt',"EmptyLineRule","skip");

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

% v_dc_inc=[0.9042 0.9531 1.0020 1.0508 1.0948 1.1388 1.1926 1.2366 1.2805 1.3245 1.3685 1.4076 1.4516 1.4907 1.5298 1.5640];
% v_dc_dec=wrev([0.8456 0.7918 0.7380 0.6794 0.6207 0.5621 0.4936 0.4301 0.3617 0.2981 0.2248 0.1711 0.1711 0.1711 0.1711]);
% v_dc=[v_dc_dec v_dc_inc];



hold on
% plot(v_dc,Abs_Current_mean)
hold on
yyaxis right
plot(vdc,Eb_off_by_Eb_ss,'r','LineWidth',3)
ylabel('E_{b-off}/E_{b-ss}','Color','r')
xlim([0.17 1])
% xline(0.43,'--r','0.43 v','FontWeight','bold','FontSize',24,'LabelHorizontalAlignment','left','LineWidth',3)
yline(0.01,'--r','LineWidth',1.5)
%ax.YAxis.Color = [1 0 0];
%ax.YAxis(2).Color = [1 0 0];
end

%%%%%%%%%%%%%%%%%%%%%% 0.5m antenna qdc %%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

plt=0;

Bits=load('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\SLICED_Inv_data_bits\SLICED_20251216-145151_dpo_LTI_ook_fc_2.880000e+07_dam_N_10_phi_100_mode_prbs_20dB_dc_1.2v_adg919_vdc_est.mat');
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


P = fullfile('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\SLICED_Current');
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

lines = readlines('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\DC voltage profile.txt',"EmptyLineRule","skip");

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

%Current_mean_smooth=smooth(vdc,Current_mean,0.12,'rloess');
% v_dc_inc=[0.9971 1.0459 1.0948 1.1388 1.1828 1.2366 1.2757 1.3196 1.3636 1.4076 1.4418 1.4858 1.5200 1.5543 1.5982 1.6276];
% v_dc_dec=wrev([0.9482 0.8944 0.8407 0.7820 0.7331 0.6745 0.6158 0.5523 0.4888 0.4252 0.3568 0.2933 0.2199 0.1711 0.1711]);
% v_dc=[v_dc_dec v_dc_inc];

%nexttile
%figure
% plot(v_dc,Current_mean_abs)
% hold on
% yyaxis right
figure
plot(vdc,Current_mean,'b','LineWidth',3) %/max(Current_mean)

grid on
grid minor
%ylim([-4e-11 6e-11])
%xlim([0.1711 1])
xlabel('V_{dc} (volts)')
ylabel('q_{dc} (C)','Color','b')
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
xline(1.125,'--b','1.125 v','FontWeight','bold','FontSize',28,'LabelHorizontalAlignment','left','LineWidth',1.5)
yline(0,'--b','LineWidth',1.5)
%ylim([-1.5e-12 1.5e-12])
end
title('$\lambda/10 - ESA$','FontSize',28,'interpreter','latex')

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0.5m antenna offbit energy %%%%%%%%%%%%%%%%%%%%%%%

clear all

plt=0;
Bits=load('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\SLICED_Inv_data_bits\SLICED_20251216-145151_dpo_LTI_ook_fc_2.880000e+07_dam_N_10_phi_100_mode_prbs_20dB_dc_1.2v_adg919_vdc_est.mat');
Bits.yrf=round(Bits.yrf);
time_stamp=[];
time_stamp_index=0;
time_stamp_locs=0;
for i=2:length(Bits.yrf)-1
time_diff=(Bits.yrf(1,i)-Bits.yrf(1,i-1));
if time_diff == 1
    time_stamp_index=time_stamp_index+1;
time_stamp(time_stamp_index)=Bits.trf(1,i-1);
time_stamp_locs(time_stamp_index)=i+10;
end
if time_diff == -1
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
plot(Bits.trf,Bits.yrf,Bits.trf(time_stamp_locs),Bits.yrf(time_stamp_locs),'o','LineWidth',1.5)
end

%% hold on
%% plot(Bits.trf,masked_data_min_current,time_stamp_locs,Bits.yrf(time_stamp_locs),'o')

P = fullfile('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\SLICED_Vrad');
S = dir(fullfile(P,'*.mat')); 
for K = 1:numel(S)
    F = fullfile(P,S(K).name);
    S(K).data = load(F);
end

bit_energy_ideal=[];

for o=1:K
single_bit_ideal=[];    
DC_DAM_vdc_min_current= S(o).data; %load('C:\Users\mpmayeka\Desktop\20240518_w_I_1010_2sw\measurements\dpo\SLICED_CURRENT\SLICED_20240518-205356_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_1010_10dB_dc_1.4v_adg919_v16.mat');
DC_DAM_vdc_min_current.yrf=interp1(DC_DAM_vdc_min_current.trf,DC_DAM_vdc_min_current.yrf,Bits.trf,'spline');
fs=1/(DC_DAM_vdc_min_current.trf(2)-DC_DAM_vdc_min_current.trf(1));
DC_DAM_vdc_min_current.yrf=lowpass(DC_DAM_vdc_min_current.yrf,30e6,fs);
single_bit_ideal=DC_DAM_vdc_min_current.yrf(1,10418:10852);
bit_energy_ideal(1,o)=sum(((single_bit_ideal).^2).*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)));
if plt==1
figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(time_stamp_locs),DC_DAM_vdc_min_current.yrf(time_stamp_locs),'o','LineWidth',1.5)
hold on
plot(Bits.trf(median_time_stamp_locs),DC_DAM_vdc_min_current.yrf(median_time_stamp_locs),'*','LineWidth',1.5)

figure
plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(I_error_locs),DC_DAM_vdc_min_current.yrf(I_error_locs),'o','LineWidth',1.5)
hold on
end

I_error=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
I_error(I_error_index)=sum(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))/length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)));

if plt==1
plot(DC_DAM_vdc_min_current.trf(1,I_error_locs(i):I_error_locs(i+1)),repelem(I_error(I_error_index),length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))),'Color','g','LineWidth',1.5)
end

end

I_error_index=0;
DC_DAM_vdc_min_current_corrected=[];
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
DC_DAM_vdc_min_current_corrected{I_error_index}=DC_DAM_vdc_min_current.yrf(1,time_stamp_locs(i):time_stamp_locs(i+1))-I_error(I_error_index);

if plt==1
plot(DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),DC_DAM_vdc_min_current_corrected{I_error_index})
end

end

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%     [pks,locs] =findpeaks(DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',6e-3);
%     pks_min_current(I_error_index,1)=pks(1,2);
%     locs_min_current(I_error_index,1)=locs(1,2);
%     [pks_inv,locs_inv] =findpeaks(-1.*DC_DAM_vdc_min_current_corrected(I_error_index,:),DC_DAM_vdc_min_current.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',6e-3);
%     pks_min_current(I_error_index,2)=-1*pks_inv(1,2);
%     locs_min_current(I_error_index,2)=locs_inv(1,2);
% 
%     if plt==1
%     plot(locs_min_current(I_error_index,:),pks_min_current(I_error_index,:),'*')
%     end
% end
% 
% pks_locs=[];
% for i=1:length(I_error)
%    for j=1:2
% pks_locs(i,j)=find(DC_DAM_vdc_min_current.trf==locs_min_current(i,j));
%    end
% end
% 
masked_data_min_current=Bits.yrf.*DC_DAM_vdc_min_current.yrf;
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
masked_data_min_current(1,time_stamp_locs(i):time_stamp_locs(i+1))=DC_DAM_vdc_min_current_corrected{I_error_index};
end
% 
% 
% loop_break=0;
% start_time_stamp_locs=[];
% for i=1:length(I_error)
%     for j=pks_locs(i,1):pks_locs(i,2)
%         if (masked_data_min_current(j) >= 0) && (loop_break == 0)
%             loop_break=1; 
%             start_time_stamp_locs(1,i)=j;
%         end
%     end
%     if loop_break == 0 
%             start_time_stamp_locs(1,i)=pks_locs(i,2);
%     end
%    loop_break=0; 
% end
% 
% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%    masked_data_min_current(1,time_stamp_locs(1,i):start_time_stamp_locs(1,I_error_index))=0;
% end
% 
% if plt==1
% figure
% plot(DC_DAM_vdc_min_current.trf,masked_data_min_current)
%    hold on
% end

final_time_stamp_locs=time_stamp_locs;

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
% final_time_stamp_locs(1,i)=start_time_stamp_locs(1,I_error_index);
% final_time_stamp_locs(1,i+1)=time_stamp_locs(1,i+1);
% end

if plt==1
plot(DC_DAM_vdc_min_current.trf(final_time_stamp_locs),masked_data_min_current(final_time_stamp_locs),'o')
end

Current=masked_data_min_current;

% I_error_index=0;
% for i=1:2:length(I_error_locs)
%     I_error_index=I_error_index+1;
%     Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))=(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))./5;
% end

if plt==1
figure
plot(DC_DAM_vdc_min_current.trf,Current)
end

Abs_Current_avg=[];
Current_avg=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Abs_Current_avg(1,I_error_index)=(sum(((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))).^2)*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1)))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
        Current_avg(1,I_error_index)=abs(sum((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))))*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
end

if plt==1
% figure
% plot(Abs_Current_avg)
figure
plot(Current_avg)
end

Abs_Current_mean(1,o)=sum(Abs_Current_avg)/length(Abs_Current_avg);
Current_mean(1,o)=sum(Current_avg)/length(Current_avg);

if plt==1
hold on
% plot(repelem(Abs_Current_mean(1,o),length(Abs_Current_avg)))
plot(repelem(Current_mean(1,o),length(Current_avg)))
end
end

if plt==0
Abs_Current_mean=[wrev(Abs_Current_mean(1,17:31)) Abs_Current_mean(1,1) Abs_Current_mean(1,2:16)];
Current_mean=[wrev(Current_mean(1,17:31)) Current_mean(1,1) Current_mean(1,2:16)];

Eb_off_by_Eb_ss=Abs_Current_mean./[wrev(bit_energy_ideal(1,17:31)) bit_energy_ideal(1,1:16)];


lines = readlines('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\DC voltage profile.txt',"EmptyLineRule","skip");

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

% v_dc_inc=[0.9042 0.9531 1.0020 1.0508 1.0948 1.1388 1.1926 1.2366 1.2805 1.3245 1.3685 1.4076 1.4516 1.4907 1.5298 1.5640];
% v_dc_dec=wrev([0.8456 0.7918 0.7380 0.6794 0.6207 0.5621 0.4936 0.4301 0.3617 0.2981 0.2248 0.1711 0.1711 0.1711 0.1711]);
% v_dc=[v_dc_dec v_dc_inc];

%Eb_off_by_Eb_ss_smooth=smooth(vdc,Eb_off_by_Eb_ss,0.15,'moving');

hold on
% plot(v_dc,Abs_Current_mean)
hold on
yyaxis right
plot(vdc,Eb_off_by_Eb_ss,'r','LineWidth',3)
ylabel('E_{b-off}/E_{b-ss}','Color','r')
%xlim([0.17 1])
xline(0.55,'--r','0.55 v','FontWeight','bold','FontSize',28,'LabelHorizontalAlignment','left','LineWidth',1.5)
yline(0.035,'--r','LineWidth',1.5)
%ax.YAxis.Color = [1 0 0];
%ax.YAxis(2).Color = [1 0 0];
end


