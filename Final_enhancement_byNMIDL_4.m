
clc ; clear ; close all
disp('Runing Code.....')
%%
tic
File = dir(fullfile('Clean_Test','*wav'));
Number_speech = size(File,1);
y_clean = cell(Number_speech,1);
y_noisy = cell(Number_speech,1);
Y_Reconstruction = cell(Number_speech,1);
Name_speech =  cell(Number_speech,1);
RMSE = zeros(Number_speech,1);
SSNR_out = zeros(Number_speech,1);
SSNR_in = zeros(Number_speech,1);
SSNR_im =  zeros(Number_speech,1);
STOI = zeros(Number_speech,1);
PESQ = zeros(Number_speech,1);
SNR_in = zeros(Number_speech,1);
SNR_out = zeros(Number_speech,1);
SDI = zeros(Number_speech,1);
SDI_new = zeros(Number_speech,1);
selected_dictionary = cell(Number_speech,1);
%%
load Ds_STFT_Clean.mat

load Dn_STFT_Babble; Dn_Babble = Dn ; clear Dn
load Dn_STFT_f16; Dn_F16 = Dn ; clear Dn
load Dn_STFT_factory ;Dn_Factory = Dn ; clear Dn
load Dn_STFT_Market ;Dn_Market = Dn ; clear Dn
load Dn_STFT_Piano ; Dn_Piano = Dn ; clear Dn
load Dn_STFT_Police ; Dn_Police = Dn ; clear Dn
load Dn_STFT_Street ; Dn_Street = Dn ; clear Dn
load Dn_STFT_Subway ; Dn_Subway = Dn ; clear Dn
load Dn_STFT_Volvo ; Dn_Volvo = Dn ; clear Dn
load Dn_STFT_White ; Dn_White = Dn ; clear Dn
Dn_total = [Dn_Babble , Dn_F16 , Dn_Factory , Dn_Market, Dn_Piano, Dn_Police , Dn_Street , Dn_Subway, Dn_Volvo, Dn_White];
%% 
fs = 8e+3;
number_frame = 4;
n_type_Noise = 10 ; %% Number Type Noise

noise_type = 'police.wav';
SNR = 10;
K_S = 30;
A= 0;
%%
for j = 1:Number_speech
    [y_clean{j},fs_orginal] = audioread(fullfile(File(j).folder,File(j).name));
    y_clean{j} = resample(y_clean{j},fs,fs_orginal);
    y_clean{j} = y_clean{j}./(max(abs(y_clean{j})));
    [noise,fs_noise] = audioread(noise_type);
    noise = resample(noise(:,1),fs,fs_noise);
    LL = length(y_clean{j});
    Aux = 0;
    while Aux == 0
        SS = randperm(length(noise),1);
        if SS>10000 && SS<length(noise) - LL -10000
            Aux =1;

        end
    end
    noise = noise(SS+1:length(y_clean{j})+SS);
    % noise = noise(18000+1:length(y_clean{j})+18000);
    P_in = sum(y_clean{j}.^2)/length(y_clean{j});
    P_noise = sum(noise.^2)/length(noise);
    factor = sqrt(P_in/(P_noise*10^(SNR/10)));
    y_noisy{j} = y_clean{j} + factor*noise;
    fs_new = 8e3;

    d = size(Dn_total,1);
    y_stft = stft(y_noisy{j},fs,'Window',hamming(d),'OverlapLength',3*d/4,'FFTLength',d);
    Y_mag = abs(y_stft);
    Y_phi = angle(y_stft);
    [~,n] = size(Y_mag);
    tic
    [Dn,selected_dictionary{j}] = Select_Dictionry_Noise(Y_mag,Dn_total,K_S,number_frame,noise_type,n_type_Noise);
    toc
    A = A + toc;
    D = [Ds , Dn];
    param.L = 30;
    param.lambda=0.15; % not more than 20 non-zeros coefficients
    param.numThreads=-1; % number of processors/cores to use; the default choice is -1
    % and uses all the cores of the machine
    param.mode=2;        % penalized formulation
    % mask = Y_mag>0;
    % alpha = mexLassoMask(Y_mag,D,mask,param);
    alpha = mexLasso(Y_mag,D,param);
    alpha = full(alpha);
    Y_mag_rec = Ds*alpha(1:size(Ds,2),:);
    Y_mag_rec_n = Dn*alpha(1+size(Ds,2):end,:);
    Y_mag_recf = (Y_mag_rec.^2./(Y_mag_rec.^2 + Y_mag_rec_n.^2)).*Y_mag;
    % Y_mag_recf = (Y_mag_rec./(Y_mag_rec + Y_mag_rec_n)).*Y_mag;
    Y_Framing_stft = Y_mag_recf.*exp(1j *Y_phi);
    Y_Framing_stft(isnan(Y_Framing_stft)) = eps;
    Y_Reconstruction{j} = real(istft(Y_Framing_stft,fs,'Window',hamming(d),'OverlapLength',3*d/4,'FFTLength',d));
    l_org = length(y_clean{j});
    l_rec = length(Y_Reconstruction{j});
    L = min(l_org,l_rec);
    y_noisy{j} = y_noisy{j}(201:L-200);
    y_clean{j} = y_clean{j}(201:L-200);
    Y_Reconstruction{j} = Y_Reconstruction{j}(201:L-200);

    SSNR_out (j) = segsnr(y_clean{j}(1:length(Y_Reconstruction{j})),Y_Reconstruction{j},8000);
    SSNR_in (j) = segsnr(y_clean{j}(1:length(Y_Reconstruction{j})),y_noisy{j},8000);
    SSNR_im(j) = SSNR_out(j)-SSNR_in(j);
    STOI(j) = stoi_i(y_clean{j}(1:length(Y_Reconstruction{j})),Y_Reconstruction{j},fs);
    PESQ(j) = pesq2(y_clean{j}(1:length(Y_Reconstruction{j})),Y_Reconstruction{j},fs);
    SNR_in(j) = 10*log10(sum(y_clean{j}(1:length(Y_Reconstruction{j})).^2)/sum((y_clean{j}(1:length(Y_Reconstruction{j})) - y_noisy{j}).^2 ));
    SNR_out(j) = 10*log10(sum(y_clean{j}(1:length(Y_Reconstruction{j})).^2)/sum((y_clean{j}(1:length(Y_Reconstruction{j})) - Y_Reconstruction{j}).^2 ));
    Name_speech{j} = File(j).name;
    % SDI(j) = speech_distortion_index(y_clean{j},Y_Reconstruction{j},8000);
    SDI_new(j) = mean((y_clean{j}-Y_Reconstruction{j}).^2)/mean(y_clean{j}.^2);
    table(Name_speech(1:j),SNR_in(1:j),SNR_out(1:j),SSNR_out(1:j),STOI(1:j) ,PESQ(1:j),SDI_new(1:j))
    toc
    toc
end
j = 6;
disp('PlayBack Input Speech:')
sound(y_noisy{j},fs)

pause(length(y_noisy{j})/fs)
disp('PlayBack Output Speech Method MOD:')
sound(Y_Reconstruction{j}, fs)
figure
subplot(211)
plot(y_noisy{j},'k')
title('Input Speech')
xlabel(['Norm2 ||Y||=',num2str(norm(y_noisy{j},2))])
subplot(212)
plot(Y_Reconstruction{j})
title('Output Speech')
xlabel(['Norm2 ||Y - DC||=',num2str(norm(y_noisy{j}-Y_Reconstruction{j},2))])
mm = randperm(n,1);
%%
t=(1:length(y_clean{j}))/fs;
figure
plot(t,y_clean{j})
axis tight
title('Clean Speech')
xlabel('Time(s)')
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';

%%
figure
plot(t,y_noisy{j})
axis tight
title('Noisy Speech')
xlabel('Time(s)')
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';
%%
figure
plot(t,Y_Reconstruction{j})
axis tight
title('Enhanced Speech')
xlabel('Time(s)')
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';


%%
figure
spectrogram(y_clean{j},hamming(160),80,1024,fs_new,'yaxis')
title('Spectrogram Clean Speech')
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';
figure
spectrogram(y_noisy{j},hamming(160),80,1024,fs_new,'yaxis')
title('Spectrogram Noisy Speech')
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';
%%
figure
spectrogram(Y_Reconstruction{j},hamming(160),80,1024,fs_new,'yaxis')
title('Spectrogram Enhanced Speech')
toc
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';
%%
figure
plot(y_noisy{j},'b','LineWidth',1)
hold on
plot(Y_Reconstruction{j},'r--','LineWidth',1)
title('Comparison of the Original and Reconstructed Speech')
axis tight
legend('Orginal Speech','Reconstructed Speech')
RMSE(end+1) = mean(RMSE);
SSNR_out(end+1) = mean(SSNR_out);
SSNR_in(end+1) = mean(SSNR_in);
SSNR_im(end+1) = mean(SSNR_im);


% FerquncySSNR(end+1) = mean(FerquncySSNR);
STOI(end+1) = mean(STOI);
PESQ(end+1) = mean(PESQ);
SNR_in(end+1) = mean(SNR_in);
SNR_out(end+1) = mean(SNR_out);
SDI(end+1) = mean(SDI);
SDI_new(end+1) = mean(SDI_new);

Name_speech{end+1} = 'Average';
selected_dictionary{end+1} = '*****';

table(Name_speech,selected_dictionary,SNR_in,SNR_out,SSNR_in,SSNR_out,SSNR_im,STOI ,PESQ,SDI_new)
ax=gca;
ax.FontSize = 12;
ax.TitleFontWeight='bold';
ax.FontName='Times New Roman';
ax.TitleFontWeight='bold';