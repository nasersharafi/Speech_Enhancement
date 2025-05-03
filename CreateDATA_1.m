clc ; clear ; close all
tic
%%% The Address of the test file
%%  Use Data 
Filelist_train = dir(fullfile('Clean_Train','*.wav')) ;

%%
num_file_train = numel(Filelist_train);
fs_new = 8000;
speech_train = cell(num_file_train,1);
speech_train_newF = cell(num_file_train,1);
framing_train = cell(num_file_train,1);
d = 256;
num_total_frame = 0;
%%

n_train = zeros(num_file_train,1);

for i=1:num_file_train 
    [speech_train{i},fs_orginal] =audioread(fullfile(Filelist_train(i).folder,Filelist_train(i).name));
    speech_train{i} = speech_train{i};
    speech_train_newF{i}=VADetection(speech_train{i},fs_new,fs_orginal);
    speech_train_newF{i} = speech_train_newF{i}./max(abs(speech_train_newF{i}));

    framing_train{i} = stft(speech_train_newF{i},fs_new,'Window',hamming(d),'OverlapLength',2*d/4,'FFTLength',d);
    [~,n_train(i)] = size(framing_train{i});
    num_total_frame = num_total_frame + n_train(i);
end

contor = 0;
for i = 1:num_file_train 
    data_out_train(:,1+contor:contor+n_train(i)) = framing_train{i};
    contor = contor + n_train(i);
end

Data_Dictionary = abs(data_out_train);
%%  Create Data Test 

save 'Data_DictionaryClean.mat' 'Data_Dictionary'
toc