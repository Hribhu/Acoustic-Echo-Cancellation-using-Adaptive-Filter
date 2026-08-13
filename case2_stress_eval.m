clc;
clear all;
close all;
rng('default');
N = 20000;
Nw=256;
fs=8000;
[yss, fs] = audioread('S_01_01.wav');
far_end=yss';
far_end=10*far_end(1:N);

[near,fs]=audioread('S_01_02.wav');
near=near';
near=10*near(1:N);

mu=0.9;
w=zeros(1,Nw);
z=zeros(1,Nw);
T = 1.2;
buffer=zeros(1,Nw);

h1=10e-6*[-436 -829 -2797 -4208 -17968 -11215 46150 34480 -10427 9049 -1309 -6320 390 -8191 -1751 -6051 -3796 -4055 -3948 -2557 -3372 -1808 -2259 -1300 -1098 -618 -340 -61 323 419 745 716 946 880 1014 976 1033 1091 1053 1042 794 831 899 716 390 313 304 304 73 -119 -109 -176 -359 -407 -512 -580 -704 -618 -685 -791 -772 -820 -839 -724];
h2=[zeros(1,40),h1,zeros(1,24)];
H1=h2;

h5=10e-6*[293 268 475 460 517 704 581 879 573 896 604 787 561 538 440 97 265 -385 20 -938 -523 -1438 -1134 -1887 -1727 -1698 -4266 -22548 -43424 2743 25897 7380 21499 11983 10400 11667 3889 7241 925 2018 -821 -2068 -2236 -4283 -3406 -5022 -4039 -4842 -4104 -4089 -3582 -2978 -2734 -1805 -1608 -645 -495 279 471 947 1186 1438 1669 1640 1901 1687 1803 1543 1566 1342 1163 963 733 665 323 221 -14 -107 -279 -379 -468 -513 -473 -588 -612 -652 -616 -566 -515 -485 -404 -344 -290 -202 -180 -123];
h6=[zeros(1,32),h5];
H2=h6;

H=2*[H1 H2];
norm2=(Nw/(Nw-sqrt(Nw)))*(1-(norm(H,1)/(sqrt(Nw)*norm(H,2))));

echo = filter(H,1,far_end);
d = echo + near;

% multi-point stress test disturbances
stress_starts = [999, 8000, 15000];
stress_lens   = [10,  25,   5];

for k = 1:length(stress_starts)
    s = stress_starts(k);
    len = stress_lens(k);
    disturbance = 10*rand(1,len);
    d(s+1:s+len) = d(s+1:s+len) + disturbance;
end

lamda=0.01;
for i = 1:N
    z(2:Nw)=z(1:Nw-1);
    z(1)=far_end(i);

    buffer(2:Nw)=buffer(1:Nw-1);
    buffer(1)=far_end(i);
    y(i)=z*w';
    e(i)=d(i)-y(i);
    farMax=max(abs(buffer));

    if abs(d(i)) < T*farMax
    w=w+mu*tanh(lamda*e(i))*z;
    end
end

SERLE1 = zeros((length(e))/10,1);

for i=1:((length(e))/100)
E1 = e((i*100)-100+1:(i*100)).^2;
D = d((i*100)-100+1:(i*100)).^2;
SERLE1(i) = sum(D)/sum(E1);
end
a = [1/3;2/3;3/3];
SERLE1 = filter(a,1,SERLE1);
ax2 = 0:100:100*(length(SERLE1)-1);
plot(ax2,10*log10(SERLE1),'linewidth',1);
hold on
plot(far_end)
xlabel('Number of iterations (n)');
ylabel('ERLE (dB)');
grid on

figure;

subplot(4,1,1)
plot(far_end)
title('Far-end Speech')
ylabel('Amplitude')
grid on

subplot(4,1,2)
plot(echo)
title('Echo Signal')
ylabel('Amplitude')
grid on

subplot(4,1,3)
plot(near)
title('Near-end Speech')
ylabel('Amplitude')
grid on

subplot(4,1,4)
plot(d)
title('Microphone Signal = Echo + Near-end + Noise')
xlabel('Samples')
ylabel('Amplitude')
grid on

figure

subplot(2,1,1)
plot(echo,'b')
hold on
plot(y,'r')
legend('Actual Echo','Estimated Echo')
title('Echo Tracking')
grid on

subplot(2,1,2)
plot(echo-y)
title('Residual Echo')
xlabel('Samples')
ylabel('Amplitude')
grid on

figure

subplot(2,1,1)
plot(near)
title('Near-end Speech')
grid on

subplot(2,1,2)
plot(e)
title('Residual Signal')
xlabel('Samples')
grid on

figure

subplot(2,1,1)

spectrogram(d,256,128,256,fs,'yaxis')

title('Before Echo Cancellation')

subplot(2,1,2)

spectrogram(e,256,128,256,fs,'yaxis')

title('After Echo Cancellation')