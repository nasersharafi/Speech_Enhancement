function segSNR = SegmentalSNR(original, reconstructed,fs ,frame_duration)
segmentLength = frame_duration*fs*1e-3;
if length(original)>length(reconstructed)
    original(length(reconstructed)+1:end)=[];    
end

numSegments = floor(length(original)/segmentLength);
segSNR = 0;

for k = 1:numSegments
    origSegment = original((k-1) * segmentLength + 1 : k * segmentLength);
    reconSegment = reconstructed((k-1) * segmentLength + 1 : k * segmentLength);
    signalEnergy = sum(origSegment.^2);
    noiseEnergy = sum((origSegment - reconSegment).^2);
    segSNR = segSNR + 10 * log10(signalEnergy/noiseEnergy);
end

segSNR = segSNR / numSegments;
end