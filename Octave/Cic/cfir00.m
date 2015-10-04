%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CIC and CFIR calculator based on Altera AN 455 Application Note
%

%%%%%% CIC filter parameters %%%%%%
R  = 50;    %% Decimation factor
M  =  1;    %% Differential delay
N  =  4;    %% Number of stages
B  = 16;    %% Coeffi. Bit-width

Fs =  10e6; %% (High) Sampling freq in Hz before decimation
Fc =  45e3; %% Pass band edge in Hz
%Fc =  (Fs/R)/4; %% Pass band edge in Hz

NFC = (Fc/(Fs/R));

%%%%%%% fir2.m parameters %%%%%%
L  = 96;      %% Filter order; must be even
Fo = R*Fc/Fs; %% Normalized Cutoff freq; 0<Fo<=0.5/M;

%%%%%%% CIC Compensator Design using fir2.m %%%%%%
p  = 2e3; %% Granularity
s  = 0.25/p; %% Step size
fp = [0:s:Fo]; %% Pass band frequency samples
fs = (Fo+s):s:0.5; %% Stop band frequency samples
f  = [fp fs]*2; %% Normalized frequency samples; 0<=f<=1
Mp = ones(1,length(fp)); %% Pass band response; Mp(1)=1
Mp(2:end) = abs( M*R*sin(pi*fp(2:end)/R)./sin(pi*M*fp(2:end))).^N;
Mf = [Mp zeros(1,length(fs))];
f(end) = 1;
h = fir2(L,f,Mf); %% Filter length L+1
h = h/max(h); %% Floating point coefficients
hz = round(h*power(2,B-1)-1); %% Fixed point coefficients


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create the Xilinx .coe file
%
fid = fopen( "cfir.coe", "w");
fprintf(fid,";\n");
fprintf(fid,"; CIC Fir compensation filter\n");
fprintf(fid,"; Coefficients generated by Octave\n");
fprintf(fid,"; CIC input sample freq Fs=%d [Hz]\n",Fs);
fprintf(fid,"; CIC rate change        R=%d\n",R);
fprintf(fid,"; CIC diff delay         M=%d\n",M);
fprintf(fid,"; CIC order              N=%d\n",N);
fprintf(fid,"; CFIR cutoff freqency  Fc=%d [Hz]\n",Fc);
fprintf(fid,"; CFIR order             L=%d\n",L);
fprintf(fid,"; CFIR coef bits         B=%d\n",B);
fprintf(fid,";\n");
fprintf(fid,"radix=10;\n");
fprintf(fid,"coefdata=\n");
for i=1:L 
   fprintf(fid,"%d,\n",hz(i));
endfor
fprintf(fid,";\n");
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create plot to show desired compensation response
%
figure(1)
plot(f,Mf);
xlabel("0.5 * Fs/R");ylabel("Resp Mag");title("CFIR Response");

%print -dpng fig1.png

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create plots for wideband cic response
%
FcicRd = linspace(1e-5,R,512); % 0 to R (denom period)
FcicHz = linspace(1e-5,Fs,512);% Fs    
FcicNm = linspace(1e-5,1,512); % Frd / R
Hcic   = abs( sin( pi*M*FcicRd) ./ sin(pi*FcicRd/R) ) .^N;

figure(2)

subplot ( 3,1,1 );
y=20*log10(abs(Hcic));
plot(FcicRd,y);
axis( [0, R, max(y)-200, max(y) ] );  
xlabel("f");ylabel("dB");
str=sprintf("CIC Response N=%d R=%d M=%d L=%d Fc=%f",N,R,M,L,NFC);
title(str);

subplot ( 3,1,2 );
plot(FcicHz,y);
axis( [0, Fs, max(y)-200, max(y) ] );  
xlabel("Hz");ylabel("dB");

subplot ( 3,1,3 );
plot(FcicNm,y);
axis( [0, 1.0, max(y)-200, max(y) ] );  
xlabel("Normalized to Fs");ylabel("dB");

%print -dpng fig2.png

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create plots for aggregate response over 2nd Nyquist
%
% [mh,mw]=freqz(h,1,length(f));
[mh,mw]=freqz(hz,1,length(f));

mh2 = [mh' fliplr(mh')]';
mh2(end)=mh2(end-1);

mh2 = [mh2' mh2']';

% mf2 is normalized Fs/R FIXME ...
mf2 = linspace(1e-3,2.0,length(mh2)); %
mc2 = abs( sin( pi*M*(mf2)) ./ sin(pi*(mf2)/R) ) .^N;
mt2 = mc2 .* mh2';

figure(3)
subplot ( 3,1,1 );
y=20*log10(abs(mc2));
plot(mf2,y);
axis( [0, 2.0, max(y)-150, max(y) ] );  
xlabel("Fs/R");ylabel("CIC(dB)");
str=sprintf("Resp Cmp (2x CIC Nyq) N=%d R=%d M=%d L=%d Fc=%f",N,R,M,L,NFC);
title(str);

subplot ( 3,1,2 );
y=20*log10(abs(mh2));
plot(mf2,y)
axis( [0, 2.0, max(y)-150, max(y) ] );  
xlabel("Fs/R");ylabel("CFIR(dB)");

subplot ( 3,1,3 );
y=20*log10(abs(mt2));
plot(mf2,y);
axis( [0, 2.0, max(y)-150, max(y) ] );  
xlabel("Fs/R");ylabel("Composite(dB)");

%print -dpng fig3.png

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)

subplot ( 3,1,1 );
y=20*log10(abs(mc2));
plot(mf2,y);
axis( [0, 0.5, max(y)-80, max(y) ] );  
xlabel("Fs/R");ylabel("CIC(dB)");
str=sprintf("Resp Cmp (1x CIC Nyq) N=%d R=%d M=%d L=%d Fc=%f",N,R,M,L,NFC);
title(str);

subplot ( 3,1,2 );
y=20*log10(abs(mh2));
plot(mf2,y);
axis( [0, 0.5, max(y)-80, max(y) ] );  
xlabel("Fs/R");ylabel("CFIR(dB)");

subplot ( 3,1,3 );
y=20*log10(abs(mt2));
plot(mf2,y);
axis( [0, 0.50, max(y)-10, max(y) ] );  
xlabel("Fs/R");ylabel("Composite(dB)");

%print -dpng fig4.png

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single plot narrow
figure(5)
hold on;
grid on;
xlabel("Fs/R");ylabel("dB");

y=20*log10(abs(mc2));
mx=max(y);
y=y .- mx;
plot(mf2,y,'b');

y=20*log10(abs(mh2));
mx=max(y);
y=y .- mx;
plot(mf2,y,'g');

y=20*log10(abs(mt2));
mx=max(y);
y=y .- mx;
plot(mf2,y,'r');

axis( [0, 0.5, -100, 10 ] );  

legend("CIC", "CFIR", "Total");
str=sprintf("Compsite Response(narrow) N=%d R=%d M=%d L=%d Fc=%f",N,R,M,L,NFC);
title(str);

print -dpng fig5.png

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single plot wide
figure(6)
hold on;
grid on;
xlabel("Fs/R");ylabel("dB");

y=20*log10(abs(mc2));
mx=max(y);
y=y .- mx;
plot(mf2,y,'b');

y=20*log10(abs(mh2));
mx=max(y);
y=y .- mx;
plot(mf2,y,'g');

y=20*log10(abs(mt2));
mx=max(y);
y=y .- mx;
plot(mf2,y,'r');

axis( [0, 2.0, -100, 10 ] );  

legend("CIC", "CFIR", "Total");
str=sprintf("Compsite Response(wide) N=%d R=%d M=%d L=%d Fc=%f",N,R,M,L,NFC);
title(str);

print -dpng fig6.png

% write out the composite response in csv
xy =[ mf2' y' ];
csvwrite( "resp.csv", xy );
