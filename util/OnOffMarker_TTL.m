classdef OnOffMarker_TTL < mladapter
    properties
        Port
        ChildProperty = 'Success'
    end
    properties (SetAccess = protected)
        State
    end
    
    methods
        function obj = OnOffMarker_TTL(varargin)
            obj@mladapter(varargin{:});
        end

        function set.Port(obj,val)
            if ~isvector(val), error('TTL Port must be a vector'); end
            non_ttl = ~ismember(val,obj.Tracker.DAQ.ttl_available);
            if any(non_ttl), error('TTL #%d is not assigned',val(find(non_ttl,1))); end
            obj.Port = val;
        end

        function init(obj,p)
            init@mladapter(obj,p);
            mglactivategraphic(obj.Tracker.Screen.TTL(:,obj.Port),true);
            obj.State = obj.Adapter.(obj.ChildProperty);
                register([p.DAQ.TTL{obj.Port}],'TTL',obj.State);
        end
        function continue_ = analyze(obj,p)
            continue_ = analyze@mladapter(obj,p);
            if obj.State~=obj.Adapter.(obj.ChildProperty)
                obj.State = obj.Adapter.(obj.ChildProperty);
                register([p.DAQ.TTL{obj.Port}],'TTL',obj.State);
            end
        end
    end
end
