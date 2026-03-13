classdef tACSStimulator < mladapter

    properties
        StartJSON
        StopJSON
        outlet
    end

    properties (Access = protected)
        stim_started = false
    end

    methods

        function obj = tACSStimulator(varargin)
            obj = obj@mladapter(varargin{:});
        end

        function init(obj,~)
            obj.stim_started = false;
        end

        function continue_ = analyze(obj,p)

            if ~obj.stim_started
                obj.outlet.push_sample({obj.StartJSON});
                obj.stim_started = true;
            end

            continue_ = obj.Adapter.analyze(p);

            if ~continue_ && obj.stim_started
                obj.outlet.push_sample({obj.StopJSON});
                obj.stim_started = false;
            end

        end

        function fini(obj,~)

            % safety stop
            if obj.stim_started
                obj.outlet.push_sample({obj.StopJSON});
                obj.stim_started = false;
            end

        end

    end

end