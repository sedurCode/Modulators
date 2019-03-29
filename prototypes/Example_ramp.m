% Number of points per signal
N = 30;

% Figure 
close('all');
Color = 0.7*[1 1 1];
Figure = figure('Color',Color);
hold('on');
grid('on');
box('on');

% Default plots
h(1) = stairs(0,'b');
h(2) = stairs(0,'g');

% Axes
set(gca,...
    'Color',    Color,...
    'Xtick',    0:10:N,...
    'Xlim',     [0,N],...
    'Ytick',    0:0.1:1,...
    'Ylim',     [-0.1 1.1],...
    'Fontsize', 8)
title('\Delta\Sigma modulation','Fontweight','Light','Fontsize',9);
xlabel('Sample number','Fontsize',8);
ylabel('Value','Fontsize',8);
legend({'Input signal','Output signal'},'Color',Color,'Fontsize',8);

% Full screen
drawnow;
warning('off','all');
jFrame = get(Figure,'JavaFrame');
jFrame.setMaximized(true);
warning('on','all');

% Test of ramp signal
Signal = linspace(0,1,11);
DSM = DeltaSigmaModulator('Oversampling',N);

for n = 1:numel(Signal)    
       
    % Delta sigma modulation
    [Signal2,SignalDS] = DSM.update(Signal(1:n));
    
    % Plot update
    set(h(1),'Ydata',Signal2);
    set(h(2),'Ydata',SignalDS);
    
    % Axes update
    set(gca,...
        'Xlim', [0 n*N],...   
        'Xtick', 0:N:n*N);
    
    % Pause
    pause(0.5);
    
end

