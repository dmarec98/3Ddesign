% ThreeDdesign is an application that could turn sounds into realistic
% spatialized sounds.
% It's using an reverb filter coupled to an HRTF filter
%
% Open source project - Created by Damien MARECHAL
% damien.marechal@hotmail.com

classdef threeDdesign < audioPlugin
    properties
        initialisation = true;
        activeReverb = false;
        activeHrtf = false;
        volume = 100;
        desiredAz = 0;
        desiredEl = 0;
        oldAz = 0;
        oldEl = 0;
        hrtf;
        desiredWetDryMix = 0.3;
        oldWetDryMix = 0.3;
        desiredRoomSize = RoomSize.small;
        oldRoomSize = RoomSize.small;
        reverb;
        
    end
    
    % Interface initialisation
    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('activeReverb','Style','checkbox'),...
            audioPluginParameter('activeHrtf', 'Style', 'checkbox'),...
            audioPluginParameter('volume', 'Mapping',{'pow',1,0,250}, 'Style', 'rotaryknob'),...
            audioPluginParameter('desiredAz', 'Style', 'rotaryknob', 'Mapping',{'pow',1,-180,180}),...
            audioPluginParameter('desiredEl', 'Style', 'rotaryknob', 'Mapping',{'pow',1,-90,90}),...
            audioPluginParameter('desiredRoomSize','Mapping',{'enum','small','medium','large'}),...
            audioPluginParameter('desiredWetDryMix', 'Style', 'rotaryknob', 'Mapping',{'pow',1,0,1})...
        );
    end
    
    methods
        function out = process(plugin,in)
            % Copy of the input signal
            processingSignal = in;
            
            % First time initialisation, any acces to audioPlugin constructor
            % May counter this with an initialisation variable
            if plugin.initialisation
                plugin.hrtf = HrtfClass();
                plugin.hrtf.update(plugin.desiredAz,plugin.desiredEl);
                plugin.reverb = ReverbClass();
                plugin.initialisation = false;
            end
            
            % Reseting the hrtf conf when update
            if (plugin.oldAz ~= plugin.desiredAz) | (plugin.oldEl ~= plugin.desiredEl)
                plugin.oldAz = plugin.desiredAz;
                plugin.oldEl  = plugin.desiredEl;
                plugin.hrtf.update(plugin.desiredAz,plugin.desiredEl);
            end
            
            % Reseting reverb conf when update
            if (plugin.oldRoomSize ~= plugin.desiredRoomSize) | (plugin.oldWetDryMix ~= plugin.desiredWetDryMix)
                plugin.oldWetDryMix = plugin.desiredWetDryMix;
                plugin.oldRoomSize = plugin.desiredRoomSize;
                plugin.reverb.update(plugin.desiredRoomSize,plugin.desiredWetDryMix);
            end
            
            % Add reverb processing
            if plugin.activeReverb
                processingSignal = plugin.reverb.working(processingSignal);
            end
            
            % Add hrtf processing
            if plugin.activeHrtf
                processingSignal = plugin.hrtf.working(processingSignal);
            end
            
            % Volume processing
            out = processingSignal * plugin.volume/100;
            
        end
    end
end
