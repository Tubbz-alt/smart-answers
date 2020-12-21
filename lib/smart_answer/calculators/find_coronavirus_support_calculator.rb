module SmartAnswer::Calculators
  class FindCoronavirusSupportCalculator
    attr_accessor :nation,
                  :need_help_with,
                  :feel_unsafe,
                  :afford_rent_mortgage_bills,
                  :afford_food,
                  :get_food,
                  :self_employed,
                  :worried_about_work,
                  :have_somewhere_to_live,
                  :have_you_been_evicted,
                  :worried_about_self_isolating,
                  :have_you_been_made_unemployed,
                  :mental_health_worries

    GROUPS = {
      feeling_unsafe: [:feel_unsafe],
      paying_bills: [:afford_rent_mortgage_bills],
      getting_food: %i[afford_food get_food],
      being_unemployed: %i[have_you_been_made_unemployed self_employed],
      going_to_work: %i[worried_about_work],
      self_isolating: %i[worried_about_self_isolating],
      somewhere_to_live: %i[have_somewhere_to_live have_you_been_evicted],
      mental_health: [:mental_health_worries],
    }.freeze

    SECTIONS = {
      feel_unsafe: lambda { |calculator|
        calculator.needs_help_with?("feeling_unsafe") && calculator.feel_unsafe != "no"
      },
      afford_rent_mortgage_bills: lambda { |calculator|
        calculator.needs_help_with?("paying_bills") && calculator.afford_rent_mortgage_bills != "no"
      },
      afford_food: lambda { |calculator|
        calculator.needs_help_with?("getting_food") && calculator.afford_food != "no"
      },
      get_food: lambda { |calculator|
        calculator.needs_help_with?("getting_food") && calculator.get_food != "yes"
      },
      self_employed: lambda { |calculator|
        calculator.needs_help_with?("being_unemployed") && calculator.self_employed != "no"
      },
      have_you_been_made_unemployed: lambda { |calculator|
        return false if calculator.have_you_been_made_unemployed.blank?

        calculator.needs_help_with?("being_unemployed") && calculator.have_you_been_made_unemployed != "no"
      },
      worried_about_work: lambda { |calculator|
        calculator.needs_help_with?("going_to_work") && calculator.worried_about_work != "no"
      },
      worried_about_self_isolating: lambda { |calculator|
        calculator.needs_help_with?("self_isolating") && calculator.worried_about_self_isolating == "yes"
      },
      have_somewhere_to_live: lambda { |calculator|
        calculator.needs_help_with?("somewhere_to_live") && calculator.have_somewhere_to_live != "yes"
      },
      have_you_been_evicted: lambda { |calculator|
        calculator.needs_help_with?("somewhere_to_live") && calculator.have_you_been_evicted != "no"
      },
      mental_health_worries: lambda { |calculator|
        calculator.needs_help_with?("mental_health") && calculator.mental_health_worries != "no"
      },
    }.freeze

    def show_group?(name)
      GROUPS[name].any? { |section| show_section?(section) }
    end

    def show_section?(name)
      SECTIONS[name].call(self)
    end

    def has_results?
      GROUPS.keys.any? { |group| show_group?(group) }
    end

    def needs_help_with?(given_help_item)
      return false if need_help_with.blank?

      need_help_with.split(",").include? given_help_item
    end

    def needs_help_in?(given_nation)
      nation == given_nation
    end

    def next_question(current_node)
      nodes = %i[
        need_help_with
        feel_unsafe
        afford_rent_mortgage_bills
        get_food
        have_you_been_made_unemployed
        worried_about_work
        worried_about_self_isolating
        have_you_been_evicted
      ]

      if nodes.slice(0..0).include?(current_node) && needs_help_with?("feeling_unsafe")
        :feel_unsafe
      elsif nodes.slice(0..1).include?(current_node) && needs_help_with?("paying_bills")
        :afford_rent_mortgage_bills
      elsif nodes.slice(0..2).include?(current_node) && needs_help_with?("getting_food")
        :afford_food
      elsif nodes.slice(0..3).include?(current_node) && needs_help_with?("being_unemployed")
        :self_employed
      elsif nodes.slice(0..4).include?(current_node) && needs_help_with?("going_to_work")
        :worried_about_work
      elsif nodes.slice(0..5).include?(current_node) && needs_help_with?("self_isolating")
        :worried_about_self_isolating
      elsif nodes.slice(0..6).include?(current_node) && needs_help_with?("somewhere_to_live")
        :have_somewhere_to_live
      elsif nodes.slice(0..7).include?(current_node) && needs_help_with?("mental_health")
        :mental_health_worries
      else
        :nation
      end
    end
  end
end
