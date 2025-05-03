clc ; clear ; close all
tic

d = 256;
num_total_frame = 0;
fs_new = 8e+3;
%%

[noise,fs_noise] = audioread('Volvo.wav');
noise = resample(noise(:,1),8000,fs_noise);
Data_Dictionary =abs(stft(noise,fs_new,'Window',hamming(d),'OverlapLength',2*d/4,'FFTLength',d));

save 'Data_Dictionary_V' 'Data_Dictionary'
toc