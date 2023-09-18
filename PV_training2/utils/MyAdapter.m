classdef MyAdapter < mladapter
    properties
        endtime
    end
    properties (SetAccess = protected)
        id
        id2
    end
    methods
        function obj = MyAdapter(varargin)
            obj@mladapter(varargin{:});
        end
%         function delete(obj)
%         end
        
        function init(obj,p)
            init@mladapter(obj,p);
            
            obj.id = mgladdcircle([1 1 1; 1 1 1], [1000 1000]);
            obj.id2 = mgladdbox([0,0,0; 0,0,0],[1920 1080]);
            mglsetproperty(obj.id,'zorder','front')
            mglsetproperty(obj.id,'origin', obj.Tracker.Screen.SubjectScreenHalfSize);
            mglsetproperty(obj.id2,'zorder','front')
            mglsetproperty(obj.id2,'origin', obj.Tracker.Screen.SubjectScreenHalfSize);
        end
        function fini(obj,p)
            fini@mladapter(obj,p);
            
            mgldestroygraphic(obj.id);
            mgldestroygraphic(obj.id2);
        end
        function continue_ = analyze(obj,p)
            analyze@mladapter(obj,p);
            obj.Success = obj.Adapter.Success;
            
            elapsed = p.scene_time();
            continue_ = elapsed < obj.endtime;
            click = obj.Tracker.KeyInput;  % Get button click data from the tracker
            if click(end)                % If the last data point of the first button is true ("clicked"),
                angle = mod(elapsed,200);   % then rotate the box.
                mglsetproperty(obj.id,'scale',angle/200);
                mglsetproperty(obj.id,'active',1)
                mglsetproperty(obj.id2,'active',1)
            else
                mglsetproperty(obj.id,'active',0)
                mglsetproperty(obj.id2,'active',0)

            end
        end
        function draw(obj,p)
            draw@mladapter(obj,p);
        end
    end
end
