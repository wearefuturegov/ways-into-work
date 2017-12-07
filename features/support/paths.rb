module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name) # rubocop:disable Metrics/CyclomaticComplexity
    case page_name

    when /the my clients/
      advisor_my_clients_path

    when /the client dashboard/
      client_dashboard_path

    when /home page/
      root_path

    when /the advisor clients/
      advisor_clients_path

    when /the advisors edit client/
      edit_advisor_client_path(@client)
      
    when /the edit action plan task page/
      edit_advisor_client_action_plan_task_path(@client, @action_plan_task)
      
    when /my profile page/
      client_profile_path

    else
      begin
        page_name =~ /the (.*) page/
        path_components = Regexp.last_match(1).split(/\s+/)
        send(path_components.push('path').join('_').to_sym)
      rescue Object
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" \
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
