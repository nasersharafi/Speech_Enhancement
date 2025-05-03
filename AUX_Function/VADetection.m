function [out_speech,out_silence]=VADetection(x,fs_new,fs_orginal)
tic

x=x(:,1);
x = resample(x,fs_new,fs_orginal);
len = length(x);
tic
result = vad1(x,fs_new,len);

toc
I = find(result);
out_speech = x(I);
out_silence = x(result==0);