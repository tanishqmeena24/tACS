classdef tACSStimAdapter < mladapter

    properties
        JSONLoad
        StartJSON
        StopJSON
        outlet
    end

    properties (Access = protected)
        stim_started = false
    end

    methods

        function obj = tACSStimAdapter(varargin)
            % obj = obj@mladapter(varargin{:});
            % % 
            obj@mladapter(varargin{1});
            obj.StartJSON = varargin{2};
            obj.StopJSON = varargin{3};
            obj.JSONLoad = varargin{4};
            obj.outlet = varargin{5};
        end

        function init(obj, p)  %init(obj,~)
            % % 
            init@mladapter(obj, p);
            obj.stim_started = false;
        end

        function continue_ = analyze(obj,p)
            continue_ = analyze@mladapter(obj, p);

            % % 
            if continue_ && ~obj.stim_started
                % % obj.outlet.push_sample({obj.JSONLoad});
                obj.outlet.push_sample({obj.StartJSON});
                obj.stim_started = true;
                disp('START')
            end

            % continue_ = obj.Adapter.analyze(p);

            if ~continue_ && obj.stim_started
                obj.outlet.push_sample({obj.StopJSON});
                obj.stim_started = false;
                disp('STOP')
            end
        obj.Success = obj.Adapter.Success;
        end

        function draw(obj,p)
            draw@mladapter(obj,p);  % Call to base class. It is necessary to complete the adapter chain.
        end

        function fini(obj,p)

            % safety stop
            if obj.stim_started
                obj.outlet.push_sample({obj.StopJSON});
                obj.stim_started = false;
                disp('STOP')
            end

            fini@mladapter(obj,p);  % Call to base class. It is necessary to complete the adapter chain.
        end

    end

end
