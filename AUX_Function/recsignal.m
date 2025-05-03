function y_out =recsignal(y_framing_rec ,fs, T_f,T_ol)
% T_F time length of the frame (ms)
% T_ol time length overlap frames (ms)
[~,n] = size(y_framing_rec);
Frame_duration=round(1e-3*T_f*fs);       %%%% Number of samples per frame
OL_duration=round(1e-3*T_ol*fs);
for i=1:n
    if i==1
        y_out((i-1)*(Frame_duration-OL_duration)+1:i*(Frame_duration-OL_duration),1)=...
            y_framing_rec(1:Frame_duration-OL_duration,i);
    else
        y_out((i-1)*(Frame_duration-OL_duration)+1:i*(Frame_duration-OL_duration),1)=...
           y_framing_rec((Frame_duration-OL_duration)+1:(Frame_duration-OL_duration)*2,i-1)+...
           y_framing_rec(1:Frame_duration-OL_duration,i);


    end
end
