require_relative "../test_helper"

module SmartAnswer
  class MultipleChoiceQuestionTest < ActiveSupport::TestCase
    test "Can list options" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
      end

      assert_equal %w[yes no], q.options
    end

    test "Can list options without transitions" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
      end

      assert_equal %w[yes no], q.options
    end

    test "Can determine next state on provision of an input" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
        next_node { outcome :fred }
      end

      current_state = State.new(:example)
      new_state = q.transition(current_state, :yes)
      assert_equal :fred, new_state.current_node
      assert new_state.frozen?
    end

    test "Can remove all options" do
      question = Question::Radio.new(nil, :example) do
        option :yes
        option :no
      end
      question.remove_options

      assert_equal [], question.options
    end

    test "Can add options after removing them" do
      question = Question::Radio.new(nil, :example) do
        option :yes
        option :no
      end
      question.remove_options
      question.option :agree
      question.option :disagree

      assert_equal %w[agree disagree], question.options
    end

    test "Next node default can be given by block" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
        next_node { outcome :baz }
      end

      new_state = q.transition(State.new(:example), :no)
      assert_equal :baz, new_state.current_node
    end

    test "Error raised on illegal input" do
      q = Question::Radio.new(nil, :example) do
        option :yes
      end

      current_state = State.new(:example)
      assert_raises SmartAnswer::InvalidResponse do
        q.transition(current_state, :invalid)
      end
    end
  end
end
