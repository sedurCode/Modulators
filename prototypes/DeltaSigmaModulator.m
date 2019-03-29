%% Delta Sigma modulator
%  Author  : E. Ogier
%  Version : 1.0
%  Release : 25th mar. 2016
%
%  OBJECT METHODS :
%  - DSM = DeltaSigmaModulator(PROPERTY1,VALUE1,PROPERTY2,VALUE2,...) : Create a DeltaSigmaModulator object and set its values (if defined)
%  - DSM.set(PROPERTY1,VALUE1,PROPERTY2,VALUE2,...)                   : Set value(s)
%  - DSM.get(PROPERTY)                                                : Get value(s)
%  - OUTPUT = DSM.update(INPUT)                                       : Update DSM OUPUT signal with INPUT signal
%  - [OVERSAMPLEDINPUT, OUTPUT] = DSM.update(INPUT)                   : Update DSM OUPUT signal with INPUT signal and get OVERSAMPLEDINPUT input signal (useful if OVERSAMPLEDINPUT>1)
%
%  OBJECT PROPERTIES <default> :
%  - SIGMA          : integrator (Sigma module) previous output                      : <0>
%  - THRESHOLD      : comparator threshold for the comparison SIGMA vs THRESHOLD     : <1>
%  - PREVIOUSOUTPUT : output previous value (comparator output, DELTA module input)  : <0>
%  - OVERSAMPLING   : oversampling factor (number of ouput per input : OVERSAMPLING) : <1>
%
%  EXAMPLE 1 :
%
%  % Number of points per signal
%  N = 30;
%  
%  % Figure
%  close('all');
%  Color = 0.7*[1 1 1];
%  Figure = figure('Color',Color);
%  hold('on');
%  grid('on');
%  box('on');
% 
%  % Default plots
%  h(1) = plot(0,'b');
%  h(2) = stairs(0,'g');
%  
%  % Axes
%  set(gca,...
%      'Color',    Color,...
%      'Xtick',    0:10:N,...
%      'Xlim',     [1,N],...
%      'Ytick',    0:0.1:1,...
%      'Ylim',     [-0.1 1.1],...
%      'Fontsize', 8);
%  title('\Delta\Sigma modulation','Fontweight','Light','Fontsize',9);
%  xlabel('Sample number','Fontsize',8);
%  ylabel('Value','Fontsize',8);
%  legend({'Input signal (DC)','Output signal'},'Color',Color,'Fontsize',8);
%  
%  % Full screen
%  drawnow;
%  warning('off','all');
%  jFrame = get(Figure,'JavaFrame');
%  jFrame.setMaximized(true);
%  warning('on','all');
%  
%  % DC test
%  DC = 0:1e-3:1;
%  DSM = DeltaSigmaModulator('Oversampling',N);
%  
%  for dc = 1:numel(DC)
%      
%      % Delta sigma modulator reset
%      set(DSM,...
%          'Sigma',          0,...
%          'PreviousOutput', 0);        
%         
%      % Delta sigma modulation
%      [Signal,SignalDS] = DSM.update(DC(dc));
%      
%      % Plot update
%      set(h(1),'Ydata',Signal);
%      set(h(2),'Ydata',SignalDS);
%      
%      % Pause
%      pause(0.01);
%      
%  end
%
%  EXAMPLE 2 :
%
%  % Number of points per signal
%  N = 100;
% 
%  % Figure
%  close('all');
%  Color = 0.7*[1 1 1];
%  Figure = figure('Color',Color);
%  hold('on');
%  grid('on');
%  box('on');
% 
%  % Second Y axes
%  [Axes,~,~] = plotyy(0,0,0,0);
%  linkaxes(Axes,'xy');
%  YTicks = linspace(0,1,11);
%  YTickLabels = arrayfun(@(y)sprintf('%G',y),YTicks-0.5,'UniformOutput',false);
%  set(Axes(1),...
%      'YColor',  'k',...
%      'Fontsize', 8);
%  set(Axes(2),...   
%      'YColor',     'y',...
%      'YLim',       [-1 +1],...
%      'Ytick',      YTicks,...
%      'Yticklabel', YTickLabels,...
%      'Fontsize',   8);
%  grid(Axes(2),'on');
% 
%  % Default plots
%  plot([1 N],0.5*[1 1],'r:');
%  h(1) = plot(0,'y');
%  h(2) = plot(0,'y');
%  h(3) = plot(0,'b');
%  h(4) = stairs(0,'g');
% 
%  % Axes
%  set(gca,...
%      'Color',    Color,...
%      'Xtick',    0:10:N,...
%      'Xlim',     [1,N],...
%      'Ytick',    0:0.5:1,...
%      'Ylim',     [-0.1 +1.1],...
%      'Fontsize', 8);
%  title('\Delta\Sigma modulation','Fontweight','Light','Fontsize',9);
%  xlabel(Axes(1),'Sample number','Fontsize',8);
%  ylabel(Axes(1),'DC','Fontsize',8);
%  ylabel(Axes(2),'AC','Fontsize',8);
%  legend([h(3) h(4)],{'Input signal (DC+AC)','Output signal'},'Color',Color,'Fontsize',8);
% 
%  % Full screen
%  drawnow;
%  warning('off','all');
%  jFrame = get(Figure,'JavaFrame');
%  jFrame.setMaximized(true);
%  warning('on','all');
% 
%  % AC test
%  DC = 1/2;
%  AC = (0:1e-3:1)/2;
%  SINWT = sin(linspace(0,2*pi,N));
% 
%  % Delta Sigma modulator
%  DSM = DeltaSigmaModulator('Oversampling',1);
% 
%  for ac = 1:numel(AC)
%     
%      % Delta sigma modulator reset
%      set(DSM,...
%          'Sigma',          0,...
%          'PreviousOutput', 0);        
%             
%      % Delta sigma modulation
%      [Signal,SignalDS] = DSM.update(DC + AC(ac) * SINWT);
%     
%      % Plot updates
%      set(h(1),'Xdata',[1 N],...
%               'Ydata',[1 1]*(DC+AC(ac)));    
%      set(h(2),'Xdata',[1 N],...
%               'Ydata',[1 1]*(DC-AC(ac)));
%      set(h(3),'Ydata',Signal);
%      set(h(4),'Ydata',SignalDS);
%     
%      % Pause
%      pause(0.01);
%     
%  end

classdef DeltaSigmaModulator < hgsetget
    
    properties
        Sigma          = 0;
        Threshold      = 1;
        PreviousOutput = 0;
        Oversampling   = 1;
    end
    
    methods
    
         % Constructor
        function Object = DeltaSigmaModulator(varargin)
            
            for v = 1:2:length(varargin)
                Property = varargin{v};
                Value = varargin{v+1}; 
                set(Object,Property,Value);                
            end
            
        end
        
        % Function 'set'
        function Object = set(Object,varargin)
            
            Properties = varargin(1:2:end);
            Values = varargin(2:2:end);            
            for n = 1:length(Properties)                
                [is, Property] = isproperty(Object,Properties{n}); 
                if is      
                    switch Property
                        case 'Oversampling'
                            if Values{n} ~= floor(Values{n})
                                error('Oversampling factor must be an integer value.')
                            end
                        case 'PreviousOutput'
                            if Values{n} < 0 || Values{n} > 1
                                error('Previous output must be a scalar between 0 and 1.')
                            end
                    end                    
                    Object.(Property) = Values{n};       
                else
                    error('Property "%s" not supported !',Properties{n});
                end                
            end
            
        end
        
        % Function 'get'
        function Value = get(varargin)
            
            switch nargin                
                case 1                    
                    Value = varargin{1};                    
                otherwise                    
                    Object = varargin{1};
                    [is, Property] = isproperty(Object,varargin{2});
                    if is                        
                        Value = Object.(Property);
                    else
                        error('Property "%s" not supported !',varargin{2});
                    end
                    
            end
            
        end
        
        % Function 'isproperty'
        function [is, Property] = isproperty(Object,Property)
            
            Properties = fieldnames(Object); 
            [is, b] = ismember(lower(Property),lower(Properties));
            Property = Properties{b};
            
        end
   
        % Function 'update'
        function varargout = update(Object,Input)
                        
            I = size(Input);
            
            % Oversampling by holding
            if I(1) >= I(2)                
                Input = repmat(Input',Object.Oversampling,1);
                Input = reshape(Input,[],1);
                S1 = I(1) * Object.Oversampling;
                S2 = 1;
            else                
                Input = repmat(Input,Object.Oversampling,1);
                Input = reshape(Input,1,[]);
                S1 = 1;
                S2 = I(2) * Object.Oversampling;
            end
            
            % Modulation
            Output = zeros(S1,S2);            
            for s = 1:max(S1,S2)
                Delta =  Input(s) - Object.PreviousOutput;
                Object.Sigma = Object.Sigma + Delta;
                Output(s) = ge(Object.Sigma,Object.Threshold);
                Object.PreviousOutput = Output(s);
            end
            
            % Outputs definition
            switch nargout
                case 1
                    varargout{1} = Output;
                case 2
                    varargout{1} = Input;
                    varargout{2} = Output;
            end
            
        end
        
    end
        
end
