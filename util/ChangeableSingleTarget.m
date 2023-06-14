classdef ChangeableSingleTarget < mlaggregator
    properties
        Target
        Threshold
        Color = [0 1 0]
        WaitForChange=0;
        ChangeVal
        ThresholdInPixels
        ChangeStep = 1.05;
    end
    properties (SetAccess = protected)
        Position
        In
        Time
    end
    properties (SetAccess = protected, Hidden)
        TouchID
        FixWindowID
    end
    properties (Access = protected)
        LastData
        LastCrossingTime
        TargetID
        TouchMode
        GraphicIdx
        PrevFrame
    end
    
    methods
        function obj = ChangeableSingleTarget(varargin)
            obj = obj@mlaggregator(varargin{:});
            obj.TouchMode = strcmp(obj.Tracker.Signal,'Touch');
        end
        function delete(obj), destroy_fixwindow(obj);end

        function set.Target(obj,val)
            if isobject(val)  % graphic adapter
                if ~isa(val,'mlgraphic'), error('Target must be a graphic adapter.'); end
                obj.Adapter{2} = val;
                if isempty(obj.GraphicIdx) %#ok<*MCSUP> 
                    obj.Target = {1};
                else
                    if ~isscalar(obj.GraphicIdx), error('Target must be a single object.'); end
                    obj.Target = {obj.GraphicIdx}; obj.GraphicIdx = [];
                end
                obj.Position = val.Position(obj.Target{1},:);
                obj.TargetID = val.GraphicID(obj.Target{1});
            elseif iscell(val)  % replay with the adapter
                obj.Target = val;
                obj.Position = obj.Adapter{2}.Position(obj.Target{1},:);
                obj.TargetID = obj.Adapter{2}.GraphicID(obj.Target{1});
            else
                obj.Adapter = obj.Adapter(1); val = val(:)';
                switch length(val)
                    case {0,2}, obj.Target = val; obj.Position = val;  % empty or coordinates
                    case 1  % TaskObject
                        if ~ismember(obj.Tracker.TaskObject.Modality(val),[1 2]), error('TaskObject#%d is not visual',val); end
                        obj.Target = val;
                        obj.Position = obj.Tracker.TaskObject.Position(val,:);
                        obj.TargetID = obj.Tracker.TaskObject.ID(val);
                    otherwise, error('Target must be a TaskObject or [x y].');
                end
            end
        end
        function setTarget(obj,val,idx)
            if ~exist('idx','var'), idx = []; end
            obj.GraphicIdx = idx;
            obj.Target = val;
        end
        function set.Threshold(obj,val)
            nval = numel(val); if nval<1 || 2<nval,  error('Threshold must be a scalar or a 1-by-2 vector'); end
            obj.Threshold = val(:)'; create_fixwindow(obj);
        end
        function set.Color(obj,val), obj.Color = val(:)'; create_fixwindow(obj); end

        function init(obj,p)
            obj.Adapter{1}.init(p);
            obj.Time = [];
            obj.TouchID = [];  % for touch
            obj.LastData = [];
            mglactivategraphic([obj.FixWindowID obj.TargetID],true);
            obj.PrevFrame = NaN;
        end
        function fini(obj,p)
            obj.Adapter{1}.fini(p);
            mglactivategraphic([obj.FixWindowID obj.TargetID],false);
        end
        function continue_ = analyze(obj,p)
            
            obj.Adapter{1}.analyze(p);
            CurrentFrame = p.scene_frame();
            if obj.PrevFrame==CurrentFrame, continue_ = ~obj.Success; return, else, obj.PrevFrame = CurrentFrame; end  % draw only once in one frame
            
            data = obj.Tracker.XYData;
            [a,b] = size(data); b = b/2;
            if 0==a, continue_ = true; return, end  % early exit, if there is no data
            
            if isempty(obj.Target), obj.Position = obj.Adapter{1}.Position; end
            ScrPosition = obj.Tracker.CalFun.deg2pix(obj.Position);
            mglsetorigin(obj.FixWindowID,ScrPosition);
            
            % determine 'in' or 'out'
            idx = 1;
            obj.In = false(a,b);
            for m=1:b
                xy = data(:,idx:idx+1);
                if isscalar(obj.ThresholdInPixels)
                    obj.In(:,m) = sum((xy-repmat(ScrPosition,a,1)).^2,2) < obj.ThresholdInPixels;
                else
                    rc = [ScrPosition ScrPosition] + obj.ThresholdInPixels;
                    obj.In(:,m) = rc(1)<xy(:,1) & xy(:,1)<rc(3) & rc(2)<xy(:,2) & xy(:,2)<rc(4);
                end
                idx = idx + 2;
            end

            % check crossing
            if isempty(obj.LastData)
                obj.LastData = obj.In(1,:);
                obj.LastCrossingTime = repmat(obj.Tracker.LastSamplePosition,1,b);
            end
            c = diff([obj.LastData; obj.In]);  % 0: no crossing, 1: cross in, -1: cross out
            obj.LastData = obj.In(end,:);      % keep the last 'in' state for next cycle

            for m=1:b
                d = find(0~=c(:,m),1,'last');  % empty when there is no crossing
                if ~isempty(d), obj.LastCrossingTime(m) = obj.Tracker.LastSamplePosition + d; end
            end

            if obj.TouchMode  % update status immediately
                on = find(obj.LastData,1);  % multiple XYs
                if isempty(on)
                    obj.Success = false;
                    if ~isempty(obj.TouchID), obj.Time = obj.LastCrossingTime(obj.TouchID); end
                    obj.TouchID = [];
                else
                    obj.Success = true;
                    obj.Time = obj.LastCrossingTime(on);
                    obj.TouchID = on;
                end
            else
                if 1~=b, error('%s cannot have multiple XYs.',obj.Tracker.Signal); end
                if isempty(d)  % update status after the signal becomes stable
                    obj.Success = obj.LastData;
                    obj.Time = obj.LastCrossingTime;
                end
            end

            % change fixation window size if needed
            if(obj.WaitForChange)
                mglactivategraphic([obj.FixWindowID],false);
                destroy_fixwindow(obj);
                if(obj.ChangeVal==1)
                    obj.Threshold = obj.Threshold * obj.ChangeStep;
                else
                    obj.Threshold = obj.Threshold / obj.ChangeStep;
                end
                create_fixwindow(obj);
                obj.WaitForChange=0;
                ScrPosition = obj.Tracker.CalFun.deg2pix(obj.Position);
                mglsetorigin(obj.FixWindowID,ScrPosition);
                mglactivategraphic([obj.FixWindowID],true);
            end
            %
            continue_ = ~obj.Success;
        end
    end
    
    methods (Access = protected)
        function create_fixwindow(obj)
            if isempty(obj.Threshold) || isempty(obj.Color), return, end
            destroy_fixwindow(obj);
            
            threshold_in_pixels = obj.Threshold * obj.Tracker.Screen.PixelsPerDegree;
            if isscalar(obj.Threshold)
                if threshold_in_pixels < min(obj.Tracker.Screen.SubjectScreenHalfSize)
                    obj.FixWindowID = mgladdcircle(obj.Color,threshold_in_pixels*2,10);
                end
                obj.ThresholdInPixels = threshold_in_pixels^2;
            else
                if all(threshold_in_pixels < obj.Tracker.Screen.SubjectScreenFullSize)
                    obj.FixWindowID = mgladdbox(obj.Color,threshold_in_pixels,10);
                end
                obj.ThresholdInPixels = 0.5*[-threshold_in_pixels threshold_in_pixels];  % [left bottom right top]
            end
            mglactivategraphic(obj.FixWindowID,false);
        end
        function destroy_fixwindow(obj), mgldestroygraphic(obj.FixWindowID); obj.FixWindowID = []; end
    end
end
