classdef RealTimeLooseHold < mladapter
    properties
        HoldTime = 0  % time to hold fixation
        BreakTime = 300 % time we can allow for blink
    end
    properties (SetAccess = protected)
        Running       % whether we are still tracking. true or false
        Waiting       % whether we are still waiting for fixation. true or false
        AcquiredTime  % trialtime when fixation was acquired
        WasGood % whether monkey fixed before
        RT
        last_fix_time
    end
    properties (Access = protected)
        EndTime
    end
    
    methods
        function obj = RealTimeLooseHold(varargin)
            obj = obj@mladapter(varargin{:});
        end
        function init(obj,p)
            init@mladapter(obj,p);
            obj.Running = true;
            obj.Waiting = true;
            obj.AcquiredTime = NaN;
            obj.WasGood = false;
            obj.last_fix_time = 0;
        end
        function fini(obj,p)
            fini@mladapter(obj,p);
            obj.RT = obj.AcquiredTime - p.FirstFlipTime;
            if obj.RT<0, obj.RT = 0; end  % RT can be negative if fixation was acquired already before the scene start
            if obj.Success && isa(obj.Adapter,'SingleTarget')  % for auto drift correction
                p.eyetargetrecord(obj.Tracker.Signal,[obj.Adapter.Position [obj.AcquiredTime 0]+obj.HoldTime*0.5]);
            end
        end
        function continue_ = analyze(obj,p)
            analyze@mladapter(obj,p);
            if ~obj.Running, continue_ = false; return, end  % If we are not tracking, return early.

            % The child adapter (obj.Adapter) of this adapter is SingleTarget
            % and its Success property is set to true when fixation is acquired.
            good = obj.Adapter.Success;  % whether fixation was acquired during the last frame. true or false
            elapsed = p.scene_time();    % time elapsed from the scene start

            % If we were waiting for fixation and it is not acquired yet,
            % check if the wait time has passed. If so, stop tracking and end the scene.
            if ~good
                %disp('was good?')
                %disp(obj.WasGood)
                %disp('break time?')
                %disp(elapsed - obj.last_fix_time)
                % if not good, we check whether the break is too long
                if  obj.WasGood && (elapsed - obj.last_fix_time <= obj.BreakTime)
                    % disp('was good and not break')
                    obj.Success = true;
                    obj.Waiting = false;
                else
                    % disp('was not good or break too long')
                    obj.Success = false;
                    obj.Waiting = true;
                    obj.WasGood = false;
                end
            else
                % if good(single target is good)
                obj.last_fix_time = elapsed;
                if obj.Waiting % which means we are waiting in the last frame.
                    % disp('waiting...')
                    obj.Waiting = false;
                    obj.EndTime = elapsed + obj.HoldTime;
                    obj.WasGood = true;
                else
                    if obj.EndTime <= elapsed
                        % disp('hold enough')
                        obj.Success = true;
                        obj.WasGood = true;
                    else
                        % disp('hold not enough')
                        obj.Success = false;
                        obj.WasGood = false; % fixa this, or hold not enough and beak would lead to reward
                    end
                end
            end
            continue_ = true;
        end
        function stop(obj)
            obj.Running = false;
        end
    end
end
