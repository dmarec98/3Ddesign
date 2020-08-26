% Open source project - Created by Damien MARECHAL
% damien.marechal@hotmail.com
classdef HrtfClass < handle
    properties
        ghrtfData;
        srcPosition;
        leftFilter;
        rightFilter;
        desiredPosition;
        lockUpdate = false;
    end
    methods
		% Constructor taking the model
        function this = HrtfClass()
            load 'ReferenceHRTF.mat' hrtfData sourcePosition;
            this.ghrtfData = permute(double(hrtfData),[2,3,1]);
            this.srcPosition = sourcePosition(:,[1,2]);
        end
		
        %void function only for update
        function update(this, newAz, newEz)
		% BLock the update function in case the function is loaded too fast
            if (this.lockUpdate == false)
                this.lockUpdate = true;
                newAz = round(newAz);
                newEz = round(newEz);
                this.desiredPosition = [-newAz newEz];
                interpolatedIR  = interpolateHRTF(this.ghrtfData,this.srcPosition,...
                                                this.desiredPosition, "Algorithm","VBAP");

                leftIR = squeeze(interpolatedIR(:,1,:))';
                rightIR = squeeze(interpolatedIR(:,2,:))';

                this.leftFilter = dsp.FIRFilter('Numerator',leftIR);
                this.rightFilter = dsp.FIRFilter('Numerator',rightIR);

                this.lockUpdate = false;
            end
        end
		
		% Process function
        function output = working(this,in)
            
            leftChannel = this.leftFilter(in(:,1));
            rightChannel = this.rightFilter(in(:,2));

            output = [leftChannel,rightChannel]*8;
            
        end
    end
end