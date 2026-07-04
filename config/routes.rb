# frozen_string_literal: true

DiscourseFreeze::Engine.routes.draw do
  get "/list" => "freeze#list"
  post "/create" => "freeze#create"
  post "/revoke" => "freeze#revoke"
  get "/search_users" => "freeze#search_users"
end

Discourse::Application.routes.draw do
  mount ::DiscourseFreeze::Engine, at: "freeze"

  # Support direct navigation (refresh/bookmark) to Ember admin plugin sub-routes.
  # Core only defines plugins/:plugin_id and plugins/:plugin_id/settings.
  get "/admin/plugins/discourse-freeze(/*path)" => "admin/plugins#show",
      constraints: StaffConstraint.new
end
