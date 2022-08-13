# frozen_string_literal: true

RSpec.describe 'RuleBoxTools::CommonUseCaseController::Orchestrator' do
  let(:controller) do
    create_fake_class('UsersController') do
      include(RuleBoxTools::CommonUseCaseController)
    end.new
  end

  let(:orchestrator) { new_orchestrator(controller) }

  context '#resource_class' do
    before { create_fake_class('CreateUser', 'UseCase') }

    it do
      orchestrator = new_orchestrator controller,
                                      method_name: :create,
                                      model_name: :user

      result = orchestrator.send :build_resource_class
      expect(result.name).to eq('CreateUser::UseCase')
    end
  end

  context '#to_pascal' do
    let(:method) { orchestrator.method(:to_pascal) }

    it do
      expect(method.call('ruby-on-rails')).to eq('RubyOnRails')
      expect(method.call('ruby_on_rails')).to eq('RubyOnRails')
      expect(method.call('ruby_on-rails')).to eq('RubyOnRails')
      expect(method.call('RubyOnRails')).to eq('RubyOnRails')
    end
  end

  context '#resolve' do
    it 'must return the value by key' do
      number = [1, 3, 4, 6].sample
      orchestrator = new_orchestrator controller, number: number

      result = orchestrator.send(:resolve, :number)
      expect(result).to eq(number)

      result = orchestrator.send(:resolve, :number) { :invalid_value }
      expect(result).to eq(number)
    end

    it 'must return result block when nil value' do
      number = [1, 3, 4, 6].sample
      orchestrator = new_orchestrator controller

      result = orchestrator.send(:resolve, :number) { number * number }
      expect(result).to eq(number * number)
    end

    it 'must return proc result as argument' do
      number = [1, 3, 4, 6].sample
      my_proc = proc { number * number }
      orchestrator = new_orchestrator controller, number: my_proc

      result = orchestrator.send(:resolve, :number)
      expect(result).to eq(number * number)
    end
  end

  private

  def new_orchestrator(controller, **args)
    klass = Object.const_get 'RuleBoxTools::CommonUseCaseController::Orchestrator'
    klass.new(controller, **args)
  end

  def create_fake_class(module_name = nil, class_name, extend: Object, &block)
    eval <<~FAKE
      #{"module #{module_name}" if module_name}
        class #{class_name} < #{extend}; end
      #{'end' if module_name}
    FAKE

    klass = Object.const_get "#{module_name}::#{class_name}"
    klass.class_exec(&block) if block
    klass
  end
end
