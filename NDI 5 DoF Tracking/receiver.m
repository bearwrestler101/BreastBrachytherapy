%% Prepare UDP connections 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% UDPs for sensor reading %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hudpr = dsp.UDPReceiver;
hudps = dsp.UDPSender;
hudpr.LocalIPPort  = 1501;

hudps.RemoteIPPort = 1500;
%hudps.LocalIPPort  = 1501;
hudps.RemoteIPAddress = '127.0.0.1';

DATA =zeros(7,10);
release(hudpr)
fprintf('Start to receive ... ');
    for j=1:1:10
        dataReceived =hudpr();
        while(isempty(dataReceived))
            dataReceived = step(hudpr);
            pause(0.1);
        end
        
        y = typecast(dataReceived, 'double');
        pause(0.1);
        
        DATA(:,j)=y;
        display(y);
    end
