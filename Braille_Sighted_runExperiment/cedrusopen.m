function cedrusopen
% Get button presses from Cedrus button box in XID mode.
%
% Typical Usage:
%
% cedrusopen;      % always call first to init structure and open port
% while <something>
%   cedrus.resettimer();
%   disp 'press a button'
%   [button time] = cedrus.waitpress(5);
%   if button == 0
%     disp 'No button pressed in 5 seconds'
%   else
%     fprintf('Button %d - Reaction Time: %d ms', button, time);
%   end
% end
% cedrus.releases = 1;  % record presses and releases
% while <something>
%   cedrus.resettimer();
%   disp 'press a button'
%   <do something else>
%   [button time press] = cedrus.getpress()
%   if button == 0
%     disp 'No button presses available'
%   else
%     pr = {"release", "press"};
%     fprintf('Button %d %s - Reaction Time: %d ms', button, pr{press+1}, time);
%   end
% end
% cedrus.close();   % close port and remove control structure
%
% button = 1-6 representing button pressed
% press = event was a press: true or false (false = a release)
% time = time of the event in milliseconds since last resettimer call
%
% Any button use creates 2 events, press and release.
% Set cedrus.releases = 1 to return releases and presses.
% By default, only presses are returned.
% Button events are stored in a FIFO stack.
% resettimer clears any events left unread.
% getpress and waitpress return an event from the FIFO.
% check cedrus.count to see how many events are on the stack.
% getpress returns button = 0 if there are no events in the stack.
% waitpress(<t>) waits for a button event or times out after <t> sec.
% <t> defaults to 60 sec.

% XID devices send six bytes of information in the following format:
% k<key info><RT>:
% The first parameter is simply the letter k, lower case
% The second parameter consists of one byte, divided as follows:
% Bits 0-3 (LSB 0 numbering) = port number.
%  Lumina LP-400: 0 = push buttons & scanner trigger; 1 = RJ45.
%  SV?1: no port 0, 1 = RJ45, 2 = voice key.
%  RB-x30 response pads: 0 = push buttons, 1 = RJ45.
% Bit 4 = action flag. set = button pressed, clear = button released.
% Bits 5-7 indicate which push button was pressed.
% Reaction time = four bytes - time elapsed (ms) since reaction time timer
% was last reset. See description of command "e5".
% Information taken from http://www.cedrus.com/xid/protocols.htm
% and http://www.cedrus.com/xid/timing.htm

global cedrus;
if isstruct (cedrus) && isfield (cedrus, 'port') 
    error ('cedrus already open');
end
evalin ('caller', 'global cedrus');
switch computer('arch')
    case 'maci64'   % device name is different for each Cedrus box
        port = 0;
        s = instrhwinfo ('serial');
        for p = 1:length(s.AvailableSerialPorts)
            if (strfind (s.AvailableSerialPorts{p}, ...
                    '/dev/tty.usbserial-142') == 1)
                port = s.AvailableSerialPorts{p};
            elseif (strfind (s.AvailableSerialPorts{p}, ...
                    '/dev/tty.usbserial-142') == 1)
                port = s.AvailableSerialPorts{p};
                break
            end
        end
        if (~ port)
            error ('Can''t find Cedrus response box');
        end
        %port = '/dev/tty.usbserial-FT4LJAJ3'; %Simulator
        %port = '/dev/tty.usbserial-FT4M0614'; %MR3 (7T)
        clear s p;
    case 'win32'
        port = 'COM4';  % all our PC's have Cedrus box on COM4
    case 'win64'
%         port = 'COM4';
        port = 'COM7';
    otherwise
        error ('Unsupported OS');
end
cedrus.getpress = @cedrusgetpress;
cedrus.resettimer = @cedrusresettimer;
cedrus.waitpress = @cedruswaitpress;
cedrus.close = @cedrusclose;
cedrus.event = {};
cedrus.releases = 0;  % by default, return only presses
cedrus.timer = timer('TimerFcn', @(~,~)0, 'StartDelay', 60);
cedrus.port = serial(port, 'BaudRate', 115200, 'DataBits', 8, ...
    'StopBits', 1, 'FlowControl', 'none', 'Parity', 'none', ...
    'BytesAvailableFcnMode', 'byte', 'BytesAvailableFcnCount', 6, ...
    'BytesAvailableFcn', @cedrusread);
fopen(cedrus.port);
fprintf(cedrus.port,['c10', char(13)]); %XID mode
cedrusresettimer

% reset reaction timer - also clears button event queue
function cedrusresettimer
global cedrus;
fprintf(cedrus.port,['e5',char(13)]);
cedrus.count = 0;

% read button press and store in event fifo
% this is a serial callback when 6 chars are in serial buffer
function cedrusread (~, ~)
global cedrus;
r = uint32(fread(cedrus.port,6));
% byte 2 determines button number, press/release and port
press = uint32(bitand (r(2), 16) ~= 0);    %binary 10000 bit 4
if press || cedrus.releases
  button = bitshift (r(2), -5);    %leftmost 3 bits
  % skip the port since we always use the buttons
  % port = bitand(r(2), 15);       %binary 01111 bottom 4 bits
  % bytes 3-6 - the time elapsed in milliseconds 
  time = ((r(6) * 256 + r(5)) * 256 + r(4)) * 256 + r(3);
  cedrus.count = cedrus.count + 1;
  cedrus.event{cedrus.count} = [button time press];
  if strcmp(get(cedrus.timer, 'Running'), 'on') == 1
      stop (cedrus.timer);
  end
end

% get first event off fifo, extract info and return it
function [button time press] = cedrusgetpress
global cedrus;
if cedrus.count > 0
  button = cedrus.event{1}(1);
  time   = cedrus.event{1}(2);
  press  = cedrus.event{1}(3);
  cedrus.event = circshift(cedrus.event, [0,-1]);
  cedrus.count = cedrus.count - 1;
else
  button = 0; time = 0; press = 0;
end

% wait for a button event
function [button time press] = cedruswaitpress (varargin)
global cedrus;
% any events already stored?
[button time press] = cedrusgetpress;
% if not, wait for timeout time or button event whichever comes first
if button == 0
  if ~isempty(varargin)
      set(cedrus.timer, 'StartDelay', varargin{1});
  end
  start (cedrus.timer);
  wait (cedrus.timer);
  [button time press] = cedrusgetpress;
end

% close port
function cedrusclose
global cedrus;
if ~isfield (cedrus, 'port') 
    error ('cedrus not open');
end
fclose(cedrus.port);
clear global cedrus;
