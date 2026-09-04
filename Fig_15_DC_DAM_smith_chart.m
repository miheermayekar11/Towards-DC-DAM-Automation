clc
close all
clear all
plt=0;
%p1=-20 dbm, p2=-15 dbm;p3=-18 dbm;p4=-11 dbm

% Vdc_opt_1m=wrev([1.376 1.044 0.873 0.689 0.520 0.386]);
% Vdc_opt_0_5m=wrev([5.506 3.942 2.644 1.985 1.449 1.041 0.746]);

Q_matched_0_5m=wrev([674 337.125 168.56 89.83 47.28 24.54 12.48])./674;
Q_matched_1m=wrev([81.76 47.33 33.31 20.75 11.84 6.34])./81.76;

% Vdc_opt_0_5m_p2=wrev([10.985 7.866 5.276 3.962 2.891 2.078 1.489]);
V1_1m_p2=wrev([2.093 1.589 1.329 1.049 0.793 0.589]);
V2_1m_p2=wrev([2.448 1.858 1.554 1.227 0.926 0.687]);

P = fullfile('C:\Users\mpmayeka\Desktop\Desktop backup 2022\AEL research credits\AEL RA\DC DAM paper\Extension of Allerton paper\Images for Final paper\Fig_7\1_m_AEC\-15 dbm');
S = dir(fullfile(P,'*.txt')); 
for K = 1:numel(S)
    F = fullfile(P,S(K).name);
    S(K).data = readmatrix(F);
end
for i=1:K
[a b]=min(abs(S(i).data(:,2)));
Vdc_opt_1m_p2(1,i)=S(i).data(b,1);
if plt==1
figure
plot(S(i).data(:,1),S(i).data(:,2))
hold on
plot(S(i).data(b,1),S(i).data(b,2),'*')
grid on
grid minor
end
end


% V1_0_5m_p2=wrev([9.437 6.757 4.532 3.403 2.484 1.785 1.279]);
% V2_0_5m_p2=wrev([9.792 7.011 4.703 3.531 2.577 1.852 1.327]);
% 

% 
% 
% % Vdc_opt_0_5m_p3=wrev([7.777 5.568 3.735 2.805 2.047 1.471 1.054]);
% V1_1m_p3=wrev([1.482 1.125 0.941 0.743 0.561 0.417]);
% V2_1m_p3=wrev([1.733 1.315 1.1 0.869 0.656 0.486]);
% 
P2 = fullfile('C:\Users\mpmayeka\Desktop\Desktop backup 2022\AEL research credits\AEL RA\DC DAM paper\Extension of Allerton paper\Images for Final paper\Fig_7\1_m_AEC\-18 dbm');
S2 = dir(fullfile(P2,'*.txt')); 
for K2 = 1:numel(S2)
    F2 = fullfile(P2,S2(K2).name);
    S2(K2).data = readmatrix(F2);
end
for i=1:K2
[a b]=min(abs(S2(i).data(:,2)));
Vdc_opt_1m_p3(1,i)=S2(i).data(b,1);
if plt==1
figure
plot(S2(i).data(:,1),S2(i).data(:,2))
hold on
plot(S2(i).data(b,1),S2(i).data(b,2),'*')
grid on
grid minor
end
end
% 
% V1_0_5m_p3=wrev([6.681 4.784 3.209 2.409 1.758 1.263 0.906]);
% V2_0_5m_p3=wrev([6.932 4.964 3.329 2.5 1.825 1.311 0.94]);
% 


%cd('C:\Users\mpmayeka\Desktop\Desktop backup 2022\AEL research credits\AEL RA\DC DAM paper\Extension of Allerton paper\Images for Final paper\Fig_7\0_5m_AEC\')
P1 = fullfile('C:\Users\mpmayeka\Desktop\Desktop backup 2022\AEL research credits\AEL RA\DC DAM paper\Extension of Allerton paper\Images for Final paper\Fig_7\0_5m_AEC\-15dbm');
S1 = dir(fullfile(P1,'*.txt')); 
for K1 = 1:numel(S1)
    F1 = fullfile(P1,S1(K1).name);
    S1(K1).data = readmatrix(F1);
end
for i=1:K1
[a b]=min(abs(S1(i).data(:,2)));
Vdc_opt_0_5m_p2(1,i)=S1(i).data(b,1);
if plt==1
figure
plot(S1(i).data(:,1),S1(i).data(:,2))
hold on
plot(S1(i).data(b,1),S1(i).data(b,2),'*')
grid on
grid minor
end
end

P3 = fullfile('C:\Users\mpmayeka\Desktop\Desktop backup 2022\AEL research credits\AEL RA\DC DAM paper\Extension of Allerton paper\Images for Final paper\Fig_7\0_5m_AEC\-18dbm');
S3 = dir(fullfile(P3,'*.txt')); 
for K3 = 1:numel(S3)
    F3 = fullfile(P3,S3(K3).name);
    S3(K3).data = readmatrix(F3);
end
for i=1:K3
[a b]=min(abs(S3(i).data(:,2)));
Vdc_opt_0_5m_p3(1,i)=S3(i).data(b,1);
if plt==1
figure
plot(S3(i).data(:,1),S3(i).data(:,2))
hold on
plot(S3(i).data(b,1),S3(i).data(b,2),'*')
grid on
grid minor
end
end


% 
% Vdc_opt_0_5m_p4=wrev([15.517 11.111 7.452 5.596 4.084 2.935 2.104]);
% Vdc_opt_1m_p4=wrev([3.879 2.944 2.463 1.945 1.468 1.088]);

% plot(Q_matched_1m,Vdc_opt_1m,'-*','Color','r')
% hold on
% plot(Q_matched_0_5m,Vdc_opt_0_5m,'--*','Color','r')

plot([0 Q_matched_1m],[0 Vdc_opt_1m_p2],'--','Color','k','LineWidth',3); %,'Color',[1 0 0 0.3],'LineWidth',2.5)
hold on

%hold off
plot([0 Q_matched_0_5m],[0 Vdc_opt_0_5m_p2],'--','Color','b','LineWidth',3)
% 
plot([0 Q_matched_1m],[0 Vdc_opt_1m_p3],'-','Color','k','LineWidth',3)
plot([0 Q_matched_0_5m],[0 Vdc_opt_0_5m_p3],'-','Color','b','LineWidth',3)

% % plot(Q_matched_1m,Vdc_opt_1m_p4,'-*','Color','k')
% % plot(Q_matched_0_5m,Vdc_opt_0_5m_p4,'--*','Color','k')
% p=plot(Q_matched_1m(1,length(Q_matched_1m)),Vdc_opt_1m_p2(1,length(Vdc_opt_1m_p2)),'diamond')
% p.MarkerFaceColor = [1 0 0];
% p.MarkerEdgeColor = [1 0 0];
% p.MarkerSize = 14;

legend('$AEC-1$ @ $P_2 \ dBm$','$AEC-2$ @ $P_2 \ dBm$','$AEC-1$ @ $P_1 \ dBm$','$AEC-2$ @ $P_1 \ dBm$','Interpreter','Latex')
%legend('1m monopole AEC @ -14 dbm','0.5m monopole AEC @ -14 dbm','1m monopole AEC @ -17 dbm','0.5m monopole AEC @ -17 dbm')
% xticks([0 20 40 60 80 100 700])
xlabel('$\overline{Q}_{Tx}$','Interpreter','Latex')
ylabel('V_{dc-opt}(volts)')
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
grid on
grid minor

