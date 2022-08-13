# frozen_string_literal: true

module RuleBoxTools
  module CommonUseCaseController
    def create
      _perform(method_name: :create)
    end

    def destroy
      _perform(method_name: :destroy)
    end

    def index
      _perform(method_name: :fetch)
    end

    def show
      _perform(method_name: :show)
    end

    def update
      _perform(method_name: :update)
    end

    private

    def _perform(**args)
      Orchestrator.new(self, **args).perform
    end

    class Orchestrator
      def initialize(controller, **args)
        @controller = controller
        @args = args
      end

      def perform
        @args[:resource_class] = resolve(:resource_class) { build_resource_class }
        @args[:use_case] = resolve(:use_case) { build_use_case }
        @args[:facade] = resolve(:facade, required: true)
        @args[:facade_result] = resolve(:perform_facade) { perform_facade }
        @args[:response_result] = resolve(:perform_response) { perform_response }
        resolve(:perform_render) { perform_render }
      end

      private

      def build_resource_class
        use_case_name = resolve :use_case_name do
          method_name = to_pascal(resolve(:method_name, required: true))
          model_name = to_pascal(resolve(:model_name) { build_model_name })
          namespace = to_pascal(resolve(:namespace) { build_nickname })

          [namespace, "#{method_name}#{model_name}", 'UseCase']
            .compact.join('::')
        end

        Object.const_get use_case_name
      end

      def build_model_name
        @controller.controller_name.singularize
      end

      def build_nickname
        nil
      end

      def build_use_case
        resource_class = @args[:resource_class]
        attributes = resolve(:attributes, required: true)
        resource_class.new(**attributes)
      end

      def perform_facade
        facade, use_case = @args.values_at :facade, :use_case
        facade.exec use_case
      end

      def perform_response
        facade = @args[:facade]
        if facade.status == :green
          { json: facade.last_result }
        else
          { json: { errors: facade.errors }, status: :unprocessable_entity }
        end
      end

      def perform_render
        @controller.render @args[:response_result]
      end

      def to_pascal(str)
        return if str.nil?

        str.to_s.split(/[-_]/)
           .map { |s| "#{s[0].upcase}#{s[1..-1]}" }
           .join
      end

      def resolve(argument_name, required: false, &block)
        argument = @args[argument_name]
        return block.call if argument.nil? && block

        if argument.is_a? Proc
          argument.call(**@args)
        elsif argument
          argument
        elsif required
          raise "Missing keyword: :#{argument_name}. Must pass { #{argument_name}: <value or proc> }!"
        end
      end
    end

    private_constant :Orchestrator
  end
end
