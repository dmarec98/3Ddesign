% Open source project - Created by Damien MARECHAL
% damien.marechal@hotmail.com
classdef ReverbClass < handle
    properties
        roomSize = RoomSize.small;
        reverb;
    end
    methods
        function this = ReverbClass()
            this.update(this.roomSize, 0.3);
        end
        function update(this, roomSize, wetImpact)
            this.roomSize = roomSize;
            switch (this.roomSize)
                case RoomSize.small
                    this.reverb = reverberator('PreDelay',0,'HighCutFrequency',200,...
                    'Diffusion',0,'DecayFactor',0.75,'HighFrequencyDamping',0.0005,...
                    'WetDryMix',wetImpact,'SampleRate',44100);
                case RoomSize.medium
                    this.reverb = reverberator('PreDelay',0,'HighCutFrequency',1000,...
                    'Diffusion',0.25,'DecayFactor',0.5,'HighFrequencyDamping',0.0005,...
                    'WetDryMix',wetImpact,'SampleRate',44100);
                case RoomSize.large
                    this.reverb = reverberator('PreDelay',0,'HighCutFrequency',20000,...
                    'Diffusion',0.5,'DecayFactor',0.25,'HighFrequencyDamping',0.0005,...
                    'WetDryMix',wetImpact,'SampleRate',44100);
            end
        end
        function output = working(this,in)
            output = this.reverb(in);
        end
    end
end