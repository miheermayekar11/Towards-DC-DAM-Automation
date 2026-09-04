% clc
% clear all
function f=charge_inc(n)
inc=sprintf('%0.1f',n);
inc=convertCharsToStrings(inc);
formatOut = 'yyyymmdd';
date=datestr(now,formatOut);
str1='C:\Users\mpmayeka\Desktop\DATA\';
str2='\measurements\dpo\data_bits\SLICED';
data_bits_path=strcat(str1,date,str2);
P=fullfile(data_bits_path);
S=dir(fullfile(P,'*.mat'));
F=fullfile(P,S(1).name);
S(1).data=load(F);

Bits=S(1).data;
%Bits=load('C:\Users\mpmayeka\Desktop\20240522_prbs inverse data bits dso ch 3\measurements\dpo\SLICED\SLICED_20240522-183051_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_prbs_10dB_dc_1.4v_adg919.mat');
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

%%plot(Bits.trf,Bits.yrf,Bits.trf(time_stamp_locs),Bits.yrf(time_stamp_locs),'o','LineWidth',1.5)

% hold on
% plot(Bits.trf,masked_data_min_current,time_stamp_locs,Bits.yrf(time_stamp_locs),'o')

str1='C:\Users\mpmayeka\Desktop\DATA\';
str2='\measurements\dpo\dc_inc_'
str3='\SLICED';
vdc_inc_path=strcat(str1,date,str2,inc,str3);
P=fullfile(vdc_inc_path);
S=dir(fullfile(P,'*.mat'));
F=fullfile(P,S(1).name);
S(1).data=load(F);

DC_DAM_vdc_min_current=S(1).data;
%DC_DAM_vdc_min_current=load('C:\Users\mpmayeka\Desktop\20240518_w_I_prbs_2sw\measurements\dpo\SLICED_CURRENT\SLICED_20240518-211513_dpo_DAM_ook_fc_2.680500e+07_dam_N_10_phi_120_mode_prbs_10dB_dc_1.4v_adg919_v27.mat');

DC_DAM_vdc_min_current.yrf=interp1(DC_DAM_vdc_min_current.trf,DC_DAM_vdc_min_current.yrf,Bits.trf,'spline');

% % figure
% % plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(time_stamp_locs),DC_DAM_vdc_min_current.yrf(time_stamp_locs),'o','LineWidth',1.5)
% % hold on
% % plot(Bits.trf(median_time_stamp_locs),DC_DAM_vdc_min_current.yrf(median_time_stamp_locs),'*','LineWidth',1.5)
% % 
% % figure
% % plot(Bits.trf,DC_DAM_vdc_min_current.yrf,Bits.trf(I_error_locs),DC_DAM_vdc_min_current.yrf(I_error_locs),'o','LineWidth',1.5)
% % hold on

I_error=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
I_error(I_error_index)=sum(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))/length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)));
%%plot(Bits.trf(1,I_error_locs(i):I_error_locs(i+1)),repelem(I_error(I_error_index),length(DC_DAM_vdc_min_current.yrf(1,I_error_locs(i):I_error_locs(i+1)))),'Color','g','LineWidth',1.5)
end

I_error_index=0;
DC_DAM_vdc_min_current_corrected=[];
for i=1:2:length(I_error_locs)
I_error_index=I_error_index+1;
DC_DAM_vdc_min_current_corrected{I_error_index}=DC_DAM_vdc_min_current.yrf(1,time_stamp_locs(i):time_stamp_locs(i+1))-I_error(I_error_index);
%%plot(Bits.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),DC_DAM_vdc_min_current_corrected{I_error_index})
end

I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    [pks,locs] =findpeaks(DC_DAM_vdc_min_current_corrected{I_error_index},Bits.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',1e-3);
    pks_min_current(I_error_index,1)=pks(1,1);
    locs_min_current(I_error_index,1)=locs(1,1);
    [pks_inv,locs_inv] =findpeaks(-1.*DC_DAM_vdc_min_current_corrected{I_error_index},Bits.trf(1,time_stamp_locs(i):time_stamp_locs(i+1)),'MinPeakDistance',0.001e-5,'MinPeakProminence',1e-3,'MinPeakWidth',3e-9);
    pks_min_current(I_error_index,2)=-1*pks_inv(1,1);
    locs_min_current(I_error_index,2)=locs_inv(1,1);
    %%plot(locs_min_current(I_error_index,:),pks_min_current(I_error_index,:),'*')
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
% % figure
% % plot(Bits.trf,masked_data_min_current)
% %    hold on

final_time_stamp_locs=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
final_time_stamp_locs(1,i)=start_time_stamp_locs(1,I_error_index);
final_time_stamp_locs(1,i+1)=time_stamp_locs(1,i+1);
end

%%plot(Bits.trf(final_time_stamp_locs),masked_data_min_current(final_time_stamp_locs),'o')

Current=masked_data_min_current;
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))=(Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1)))./5;
end

% % figure
% % plot(Bits.trf,Current)

Current_avg=[];
I_error_index=0;
for i=1:2:length(I_error_locs)
    I_error_index=I_error_index+1;
    Current_avg(1,I_error_index)=(sum((Current(1,final_time_stamp_locs(1,i):final_time_stamp_locs(1,i+1))))*(DC_DAM_vdc_min_current.trf(1,2)-DC_DAM_vdc_min_current.trf(1,1))); %/(DC_DAM_vdc_min_current.trf(1,i+1)-DC_DAM_vdc_min_current.trf(1,i));
end
% % figure
% % plot(Current_avg)

Current_mean=sum(Current_avg)/length(Current_avg);
% % hold on
% % plot(repelem(Current_mean,length(Current_avg)))
f=Current_mean;
%f=n+1;
end











