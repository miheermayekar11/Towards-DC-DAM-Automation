clc
close all
clear all
%val = pyrunfile("C:\Users\mpmayeka\Desktop\untitled1.py","value",num=10);
in_pwr = input('Reset the Arduino and Enter input power in dBm: ');
disp('Optimization is in progress.....') 
dc_vltg = 5.021e-14*in_pwr^9 + 3.492e-12*in_pwr^8 + 2.057e-10*in_pwr^7 + 1.28e-08*in_pwr^6 + 6.757e-07*in_pwr^5 + 2.928e-05*in_pwr^4 + 0.001017*in_pwr^3 + 0.0265*in_pwr^2 + 0.4603*in_pwr + 3.998;
Estimated_DC_voltage = dc_vltg
dc_vltg = round(dc_vltg,1); 
dc_vltg = 10*dc_vltg;
%dc_vltg = 1;
inc = 1;y_inc=-1;
dec = 1;y_dec=1;
inc_count=0;
dec_count=0;
y_inc_array=[];y_dec_array=[];vdc_array=[];
close = 1;
val_inc = pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_estimate.py","value_inc",num=dc_vltg);
y_est=charge_est(1);
lines = readlines('C:\Users\mpmayeka\Desktop\DATA\DC voltage profile.txt',"EmptyLineRule","skip");
k = strfind(lines(length(lines),1),'Voltage= ');
vdc=str2double(extractBetween(lines(length(lines),1),k+9,k+9+6));
vdc_estimated=vdc;
VDC=sprintf('%.4f',vdc);
figure
plot(vdc,y_est,'r--*','LineWidth',2);drawnow
xlabel('Vdc (volts)','FontSize',20,'FontWeight','bold')
ylabel('Charge(C)','FontSize',20,'FontWeight','bold')
xl=xline(vdc,'--',strcat('Vdc-estimate = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'right';
yl=yline(0,'b--','Threshold = 0 C','FontSize',12,'LineWidth',2);
yl.LabelVerticalAlignment = 'middle';
yl.LabelHorizontalAlignment = 'center';
grid on
grid minor
hold on

while y_est < 0 && y_inc < 0 %&& y_inc <= 2 
%while inc < 3
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_increment.py","value_inc",increment=inc);
y_inc=charge_inc(inc);
y_inc_array=[y_inc_array y_inc];
lines = readlines('C:\Users\mpmayeka\Desktop\DATA\DC voltage profile.txt',"EmptyLineRule","skip");
k = strfind(lines(length(lines),1),'Voltage= ');
vdc=str2double(extractBetween(lines(length(lines),1),k+9,k+9+6));
vdc_array=[vdc_array vdc];
plot(vdc,y_inc,'r--*','LineWidth',2);drawnow
inc = inc+1;
if y_inc > 0
%if inc == 3
if length(y_inc_array) == 1
 if abs(y_inc_array(1,length(y_inc_array))-0)<abs(y_est-0)
    inc=inc-1;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_inc.py","value_inc",increment=inc);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end
if abs(y_inc_array(1,length(y_inc_array))-0)>abs(y_est-0)
    pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_est.py","value_inc",increment=inc);    
VDC=sprintf('%.4f',vdc_estimated);
xl=xline(vdc_estimated,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'Right';
disp('Optimization completed')
Vdc_optimum = vdc_estimated
end
end
if length(y_inc_array) > 1
if abs(y_inc_array(1,length(y_inc_array))-0)<abs(y_inc_array(1,length(y_inc_array)-1)-0)
    inc=inc-1;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_inc.py","value_inc",increment=inc);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end
if abs(y_inc_array(1,length(y_inc_array))-0)>abs(y_inc_array(1,length(y_inc_array)-1)-0)
    inc=inc-2;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_inc.py","value_inc",increment=inc);    
VDC=sprintf('%.4f',vdc_array(1,length(vdc_array)-1));
xl=xline(vdc_array(1,length(vdc_array)-1),'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc_array(1,length(vdc_array)-1)
end
end
end
if y_inc == 0
   inc=inc-1;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_inc.py","value_inc",increment=inc);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end
end

while y_est > 0 && y_dec > 0 %&& y_dec <= 2
%while dec < 3
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_decrement.py","value_inc",decrement=dec);
y_dec=charge_dec(dec);
y_dec_array=[y_dec_array y_dec];
lines = readlines('C:\Users\mpmayeka\Desktop\DATA\DC voltage profile.txt',"EmptyLineRule","skip");
k = strfind(lines(length(lines),1),'Voltage= ');
vdc=str2double(extractBetween(lines(length(lines),1),k+9,k+9+6));
vdc_array=[vdc_array vdc];
plot(vdc,y_dec,'r--*','LineWidth',2);drawnow
dec=dec+1
if y_dec < 0
%if dec == 3
if length(y_dec_array) == 1
   if abs(y_dec_array(1,length(y_dec_array))-0)<abs(y_est-0)
    dec=dec-1;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_dec.py","value_inc",decrement=dec);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end
if abs(y_dec_array(1,length(y_dec_array))-0)>abs(y_est-0)
    pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_est.py","value_inc",decrement=dec);    
VDC=sprintf('%.4f',vdc_estimated);
xl=xline(vdc_estimated,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'Right';
disp('Optimization completed')
Vdc_optimum = vdc_estimated
end
end
if length(y_dec_array) > 1
if abs(y_dec_array(1,length(y_dec_array))-0)<abs(y_dec_array(1,length(y_dec_array)-1)-0)
    dec=dec-1;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_dec.py","value_inc",decrement=dec);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end
if abs(y_dec_array(1,length(y_dec_array))-0)>abs(y_dec_array(1,length(y_dec_array)-1)-0)
    dec=dec-2;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_dec.py","value_inc",decrement=dec);    
VDC=sprintf('%.4f',vdc_array(1,length(vdc_array)-1));
xl=xline(vdc_array(1,length(vdc_array)-1),'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc_array(1,length(vdc_array)-1)
end
end
end
if y_dec == 0
    dec=dec-1;
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_dec.py","value_inc",decrement=dec);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end
end

% if charge_inc >= 0 || charge_dec >= 0 || charge_est == 0

if y_est == 0
%if charge_est == 0
pyrunfile("C:\Users\mpmayeka\Desktop\Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001\Python - MATLAB  automated DC DAM scripts\Python DAM experiment scripts\vdc_opt_est.py","value_inc",decrement=dec);    
VDC=sprintf('%.4f',vdc);
xl=xline(vdc,'--',strcat('Vdc-optimum = ',VDC,'v'),'FontSize',12,'LineWidth',2);
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'left';
disp('Optimization completed')
Vdc_optimum = vdc
end

%pyrunfile("C:\Users\mpmayeka\Desktop\Python DAM experiment scripts\untitled2.py","value_inc",arduino_close=close);