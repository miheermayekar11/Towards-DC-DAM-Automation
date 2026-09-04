clc
close all
clear all
Q_1m_lossless=81.76;
Q_0_5m_lossless=674;

S_1m = sparameters('E:\1_0_5m_antenna_OTA_final\MATLAB scripts for final paper\1M_OTA.s1p');
S_0_5m = sparameters('E:\1_0_5m_antenna_OTA_final\MATLAB scripts for final paper\0.5M_OTA.s1p');

%rfplot(S_1m)

[a_1m b_1m]=min(20*log10(abs(S_1m.Parameters)));
S_1m.Frequencies(b_1m);
% xline(S_1m.Frequencies(b_1m,1)/1e6,'--b','LineWidth',3)
% yline(-3,'--b','LineWidth',3)

AEC_1m_3db_values = (20*log10(abs(S_1m.Parameters)))+3;

[a_1m_3db_min b_1m_3db_min]=min(abs(AEC_1m_3db_values(1,1,1:b_1m)));
[a_1m_3db_max b_1m_3db_max]=min(abs(AEC_1m_3db_values(1,1,b_1m+1:length(AEC_1m_3db_values))));

% xline(S_1m.Frequencies(b_1m_3db_min,1)/1e6,'--b','LineWidth',3)
% xline(S_1m.Frequencies(b_1m_3db_max+b_1m,1)/1e6,'--b','LineWidth',3)

a_1m_3db_min=20*log10(abs(S_1m.Parameters(1,1,b_1m_3db_min)));
a_1m_3db_max=20*log10(abs(S_1m.Parameters(1,1,b_1m_3db_max+b_1m)));
S_1m.Frequencies(b_1m_3db_max+b_1m,1);
S_1m.Frequencies(b_1m_3db_min,1);

Q_1m=(S_1m.Frequencies(b_1m)/(S_1m.Frequencies(b_1m_3db_max+b_1m,1)-S_1m.Frequencies(b_1m_3db_min,1)))/Q_1m_lossless

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0.5m AEC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure
% rfplot(S_0_5m)

[a_0_5m b_0_5m]=min(20*log10(abs(S_0_5m.Parameters)));
S_0_5m.Frequencies(b_0_5m);
% xline(S_0_5m.Frequencies(b_0_5m,1)/1e6,'--b','LineWidth',3)
% yline(-3,'--b','LineWidth',3)

AEC_0_5m_3db_values = (20*log10(abs(S_0_5m.Parameters)))+3;

[a_0_5m_3db_min b_0_5m_3db_min]=min(abs(AEC_0_5m_3db_values(1,1,1:b_0_5m)));
[a_0_5m_3db_max b_0_5m_3db_max]=min(abs(AEC_0_5m_3db_values(1,1,b_0_5m+1:length(AEC_0_5m_3db_values))));

% xline(S_0_5m.Frequencies(b_0_5m_3db_min,1)/1e6,'--b','LineWidth',3)
% xline(S_0_5m.Frequencies(b_0_5m_3db_max+b_0_5m,1)/1e6,'--b','LineWidth',3)

a_0_5m_3db_min=20*log10(abs(S_0_5m.Parameters(1,1,b_0_5m_3db_min)));
a_0_5m_3db_max=20*log10(abs(S_0_5m.Parameters(1,1,b_0_5m_3db_max+b_0_5m)));
S_0_5m.Frequencies(b_0_5m_3db_max+b_0_5m,1);
S_0_5m.Frequencies(b_0_5m_3db_min,1);

Q_0_5m=(S_0_5m.Frequencies(b_0_5m)/(S_0_5m.Frequencies(b_0_5m_3db_max+b_0_5m,1)-S_0_5m.Frequencies(b_0_5m_3db_min,1)))/Q_0_5m_lossless

open('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_1m\Qdc_vs_Vdc.fig');
a_N10_neg14dbm=get(gca,'Children')
x_N10_neg14dbm=a_N10_neg14dbm.XData;
y_N10_neg14dbm=a_N10_neg14dbm.YData;

[min_N10_neg14dbm I_N10_neg14dbm] =min(abs(y_N10_neg14dbm));
hold on
plot(x_N10_neg14dbm(1,I_N10_neg14dbm),y_N10_neg14dbm(1,I_N10_neg14dbm),'diamond')
hold off

close all
open('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-11dbm_1m\Qdc_vs_Vdc.fig');
a_N10_neg17dbm=get(gca,'Children')
x_N10_neg17dbm=a_N10_neg17dbm.XData;
y_N10_neg17dbm=a_N10_neg17dbm.YData;

[min_N10_neg17dbm I_N10_neg17dbm] =min(abs(y_N10_neg17dbm));
hold on
plot(x_N10_neg17dbm(1,I_N10_neg17dbm),y_N10_neg17dbm(1,I_N10_neg17dbm),'diamond')
hold off

close all
open('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-14dbm_0.5m\Qdc_vs_Vdc.fig');
a_N10_neg14dbm_0_5m=get(gca,'Children')
x_N10_neg14dbm_0_5m=a_N10_neg14dbm_0_5m.XData;
y_N10_neg14dbm_0_5m=a_N10_neg14dbm_0_5m.YData;
yy2 = smooth(x_N10_neg14dbm_0_5m,y_N10_neg14dbm_0_5m,0.3,'rloess');

[min_N10_neg14dbm_0_5m I_N10_neg14dbm_0_5m] =min(abs(yy2));
hold on
plot(x_N10_neg14dbm_0_5m,yy2)
plot(x_N10_neg14dbm_0_5m(1,I_N10_neg14dbm_0_5m),y_N10_neg14dbm_0_5m(1,I_N10_neg14dbm_0_5m),'diamond')
hold off

close all
open('E:\1_0_5m_antenna_OTA_final\20251216\measurements\dpo\N10_prbs__-11dbm_0.5m\Qdc_vs_Vdc.fig');
a_N10_neg17dbm_0_5m=get(gca,'Children')
x_N10_neg17dbm_0_5m=a_N10_neg17dbm_0_5m.XData;
y_N10_neg17dbm_0_5m=a_N10_neg17dbm_0_5m.YData;
yy3 = smooth(x_N10_neg17dbm_0_5m,y_N10_neg17dbm_0_5m,0.3,'rloess');

[min_N10_neg17dbm_0_5m I_N10_neg17dbm_0_5m] =min(abs(yy3));
hold on
plot(x_N10_neg17dbm_0_5m,yy3)
plot(x_N10_neg17dbm_0_5m(1,I_N10_neg17dbm_0_5m),y_N10_neg17dbm_0_5m(1,I_N10_neg17dbm_0_5m),'diamond')
hold off

open('E:\1_0_5m_antenna_OTA_final\MATLAB scripts for final paper\DC_DAM_smith_chart_antenna_OTA.fig');
hold on
err_1_pos = 0.0297;
err_1_neg = 0.1703;
plt_1=errorbar(Q_1m,x_N10_neg14dbm(1,I_N10_neg14dbm),err_1_neg,err_1_pos,'o','Color','k')
plt_1.MarkerFaceColor = [0 0 0];
plt_1.MarkerSize = 8;
plt_1.MarkerEdgeColor = [0 0 0];

err_2_pos = 0.112;
err_2_neg = 0.188;
plt_2=errorbar(Q_1m,x_N10_neg17dbm(1,I_N10_neg17dbm),err_2_neg,err_2_pos,'o','Color','k')
% plt_2.MarkerFaceColor = [0 0 0];
plt_2.MarkerSize = 8;
% plt_2.MarkerEdgeColor = [0 0 0];

err_3_pos = 0.1601;
err_3_neg = 0.0399;
plt_3=errorbar(Q_0_5m,x_N10_neg14dbm_0_5m(1,I_N10_neg14dbm_0_5m),err_3_neg,err_3_pos,'o','Color','b')
plt_3.MarkerFaceColor = [0 0 1];
plt_3.MarkerSize = 8;
plt_3.MarkerEdgeColor = [0 0 1];

err_4_pos = 0.0518;
err_4_neg = 0.4982;
plt_4=errorbar(Q_0_5m,x_N10_neg17dbm_0_5m(1,I_N10_neg17dbm_0_5m),err_4_neg,err_4_pos,'o','Color','b')
plt_4.MarkerSize = 8;

% legend('1m monopole AEC @ -20 dbm','0.5m monopole AEC @ -20 dbm','1m monopole AEC @ -14 dbm','0.5m monopole AEC @ -14 dbm','1m monopole AEC @ -17 dbm','0.5m monopole AEC @ -17 dbm','1m monopole AEC @ -11 dbm','0.5m monopole AEC @ -11 dbm','V_{dc-opt-zero-charge}','V_{dc-opt-zero-charge}','V_{dc-opt-zero-charge}','V_{dc-opt-zero-charge}')
legend('','','','','$\lambda/10 \ Antenna \ P_1 \ dbm$','$\lambda/10 \ Antenna \ P_2 \ dbm$','$\lambda/20 \ Antenna \ P_1 \ dbm$','$\lambda/20 \ Antenna \ P_2 \ dbm$','Interpreter','latex')