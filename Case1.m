clc;
clear all;
close all;
rng('default');
N = 24800;
Nw=256;
fs=8000;
[yss, fs] = audioread('S_01_01.wav');
input=yss';
input=input*10;
 dim=length(input);
input1=rand(1,dim)-0.5;
noise = awgn(input1,30)-input1;

mu=0.1; 
w=zeros(1,Nw);  
z=zeros(1,Nw);

%first impulse response
h1=10e-6*[-436 -829 -2797 -4208 -17968 -11215 46150 34480 -10427 9049 -1309 -6320 390 -8191 -1751 -6051 -3796 -4055 -3948 -2557 -3372 -1808 -2259 -1300 -1098 -618 -340 -61 323 419 745 716 946 880 1014 976 1033 1091 1053 1042 794 831 899 716 390 313 304 304 73 -119 -109 -176 -359 -407 -512 -580 -704 -618 -685 -791 -772 -820 -839 -724];
h2=[zeros(1,40),h1,zeros(1,24)];
H1=h2;
% norm1=(Nw/(Nw-sqrt(Nw)))*(1-(norm(H1,1)/(sqrt(Nw)*norm(H1,2))));
%fifth impulse response
h5=10e-6*[293 268 475 460 517 704 581 879 573 896 604 787 561 538 440 97 265 -385 20 -938 -523 -1438 -1134 -1887 -1727 -1698 -4266 -22548 -43424 2743 25897 7380 21499 11983 10400 11667 3889 7241 925 2018 -821 -2068 -2236 -4283 -3406 -5022 -4039 -4842 -4104 -4089 -3582 -2978 -2734 -1805 -1608 -645 -495 279 471 947 1186 1438 1669 1640 1901 1687 1803 1543 1566 1342 1163 963 733 665 323 221 -14 -107 -279 -379 -468 -513 -473 -588 -612 -652 -616 -566 -515 -485 -404 -344 -290 -202 -180 -123];
h6=[zeros(1,32),h5];
H2=h6;
% norm2=(Nw/(Nw-sqrt(Nw)))*(1-(norm(H2,1)/(sqrt(Nw)*norm(H2,2))));
H=2*[H1 H2];
norm2=(Nw/(Nw-sqrt(Nw)))*(1-(norm(H,1)/(sqrt(Nw)*norm(H,2))));
d=filter(H,1,input)+noise;
lamda=0.01;
for i = 1:N
%         ZA-LMS/F parameter*

    z(2:Nw)=z(1:Nw-1);
    z(1)=input(i);
    y(i)=z*w';
    e(i)=d(i)-y(i);
    w=w+mu*tanh(lamda*e(i))*z;   

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
plot(input)
xlabel('Number of iterations (n)');
ylabel('ERLE (dB)');
% legend('NA-LMS/F','RNA-LMS/F','Proposed','Location','best');
