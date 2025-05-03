function sdi = speech_distortion_index(clean_speech, distorted_speech, fs)
% Compute the Speech Distortion Index (SDI) between clean and distorted speech signals

% Ensure both signals have the same length
min_len = min(length(clean_speech), length(distorted_speech));
clean_speech = clean_speech(1:min_len);
distorted_speech = distorted_speech(1:min_len);

% Compute the mean square error (MSE) between clean and distorted speech
mse = mean((clean_speech - distorted_speech).^2);

% Compute the reference power
ref_power = mean(clean_speech.^2);

% Compute the SDI
sdi = 10 * log10(ref_power / mse);

% Print the SDI value
fprintf('Speech Distortion Index (SDI): %.2f dB\n', sdi);
end
