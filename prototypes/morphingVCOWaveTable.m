% Initialise Environment Params
sampleRate = 48000;
sampleStep = 1/sampleRate;
frequency = 10;
freq = frequency;
cyclePeriod = sampleRate / frequency;
morphingPeriod = sampleRate / 4;
t = (0 : sampleRate-1) / sampleRate;
T = 10.0;

% Create Waveform Tables
sine =  sin(2.0 * pi * freq .* t);
counter = 0;
triangleCounter = 0;
morpherCounter = 0;
morphingCounter = 0;
for index = 1 : length(sine)
    counter = counter + 1;
    morpherCounter = morpherCounter + 1;
%     if morpherCounter > morphingPeriod
%         morpherCounter = 1;
%     end
    if counter > cyclePeriod
        counter = 0;
    end
    if counter > cyclePeriod / 2
        square(index) = 0;
        triangleCounter = triangleCounter - 1;
    else
        square(index) = 1;
        triangleCounter = triangleCounter + 1;
    end
    
     if morpherCounter > morphingPeriod
         morphingCounter = 0;
     elseif morpherCounter > morphingPeriod / 2
        morphingCounter = morphingCounter - 1;
     elseif morpherCounter < morphingPeriod / 2
        morphingCounter = morphingCounter + 1;
     end
    morph(index) = morphingCounter / (morphingPeriod / 2);
    triangle(index) = triangleCounter / (cyclePeriod/2);
    saw(index) = counter / cyclePeriod;
    random(index) = 2 * rand() - 1;
end

signals = [sine' triangle' saw' square'];

morph = morph(1 : ceil(length(morph)/2));

morphMatrix = [morph' ...
               circshift(morph, morphingPeriod / 2)'...
               circshift(morph, morphingPeriod)'...
               circshift(morph, morphingPeriod * 1.5)'];
           
morphMatrix = circshift(morphMatrix, -morphingPeriod / 2);
% Create test control inputs
% rho = 4 * sin(2 * pi * 16 .* t);
rho = zeros(1, length(t));
phase = 0;
delta = sin(2 * pi * 1 .* t);
% Run process
% for index = 1 : length(sine)
%     rho(index) = abs(rho(index)) + 1.0;
%     WF2Gain = rho(index) - floor(rho(index));
%     WF1Gain = 1.0 - WF2Gain;
%     out(index) = signals(ceil(rho(index)), index) * WF1Gain + signals(round(rho(index)), index) * WF2Gain;
% end

% index = 0;
% for time = 0 : sampleStep : T
%     index = index + 1;
%     rho(index) = abs(rho(index)) + 1.0;
%     WF2Gain = rho(index) - floor(rho(index));
%     WF1Gain = 1.0 - WF2Gain;
%     out(index) = signals(ceil(rho(index)), index) * WF1Gain + signals(round(rho(index)), index) * WF2Gain;
% end
% 
% subplot(2, 1, 1);
% plot(out)
% subplot(2, 1, 2);
% OUT = fft(out);
% OUT = OUT(1 : floor(length(OUT)/2));
% freqArray = 0 : (sampleRate/2) / length(OUT) : sampleRate/2 - 1;
% semilogx(freqArray, db(OUT));
% plot(rho)
% % xlim([0 480*2]);

%%
% rate = 3;
% index = 1;
% for step = 0 : sampleStep : T - sampleStep
%     out(index) = sine(1);
%     index = index + 1;
%     sine = circshift(sine, rate);
% end
% % plot([sine' out']);
% plot(morphMatrix)

%%
morphMat = morphMatrix;
outRate = 10;
index = 1;
morphOffset = 6000 * 0 + 1;
% morphVector = morphOffset + (0 * [round((1 + sin(2 * pi * 0.1 .* ((0 : floor(sampleRate * T)-1) / sampleRate))) * floor(size(morphMat, 1)/2)) 1]);
% morphVector = [morphOffset zeros(ceil(sampleRate * T) + 1,1)'];
LFOt = (0 : ceil(sampleRate * T)-1) / sampleRate;
LFO = ceil(6000 * (0 * (1 + 0.5 * sin(2 * pi * 0.1 .* LFOt))));
morphVector = [morphOffset LFO];
morphPointer = morphVector(1);
for step = 0 : sampleStep : T - sampleStep
    out(index) = sum(morphMat(morphPointer, :) .* signals(1, :));
    index = index + 1;
    signals = circshift(signals, outRate);
    morphPointer = morphPointer + morphVector(index);
    if  morphPointer > size(morphMat, 1)
        morphPointer = 1 + (morphPointer - size(morphMat, 1));
    end
    if morphPointer < 1 
        morphPointer = size(morphMat, 1) - abs(morphPointer);
    end
end
% out = doFilter(out);
% plot(out);
plot([out' (LFO./max(LFO))']);
% xlim([4801*1 4801*5]);
% plot([sine' out']);
% % % plot(morphMatrix)