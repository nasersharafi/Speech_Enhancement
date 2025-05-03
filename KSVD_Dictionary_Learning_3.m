%Learning speech dictionary based on speech frames using KSVD
clc
close all
clear 

load Data_DictionaryClean.mat
Y= Data_Dictionary;

sy=size(Y,1);
Ls=4*sy(1);
%m=50;

Dinit=normcols(rand(size(Y,1),Ls));

params.data=Y;
params.EData=0.01;
params.Tdata=30;
params.dictsize=Ls;
params.inintdict=Dinit;
params.iternum=50;
params.memusage = 'high';
params.codemode='sparsity';

[Ds,X,err]= ksvd(params,'');
figure; plot(err); title('K-SVD error convergence for speech frames dictionary learning');
xlabel('Iteration'); ylabel('RMSE');

save('Ds_STFT_Clean','Ds','err')