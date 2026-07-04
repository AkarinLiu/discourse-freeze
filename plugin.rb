# frozen_string_literal: true

# name: discourse-freeze
# about: 账号冻结插件 - 允许管理员冻结用户账号，提供账号被盗、用户已离世两种冻结原因
# version: 0.1.0
# authors: AkarinLiu
# url: https://github.com/AkarinLiu/discourse-freeze.git
# required_version: 2.7.0

register_asset "stylesheets/freeze.scss"

register_svg_icon "snowflake"
register_svg_icon "ban"
register_svg_icon "dove"
register_svg_icon "lock"
register_svg_icon "cross"

enabled_site_setting :freeze_enabled

add_admin_route "freeze.title", "discourse-freeze", use_new_show_route: true

module ::DiscourseFreeze
  PLUGIN_NAME = "discourse-freeze"

  FREEZE_REASONS = %w[account_stolen user_deceased].freeze

  FREEZE_REASON_LABELS = {
    "account_stolen" => "账号被盗",
    "user_deceased"  => "用户已离世"
  }.freeze
end

require_relative "lib/discourse_freeze/engine"

after_initialize do
  # Add frozen? method to User model
  add_to_class(:user, :frozen?) do
    UserFreezeRecord.currently_frozen_for?(self.id)
  end

  # Block frozen users from accessing the site on every request
  ::ApplicationController.class_eval do
    prepend_before_action :check_user_frozen, if: :current_user

    def check_user_frozen
      if current_user.frozen?
        render json: { errors: [I18n.t("freeze.errors.frozen_account")] }, status: 403
      end
    end
  end

  # Expose freeze status in user serializer for profile display
  add_to_serializer(
    :user,
    :frozen_status,
    include_condition: -> { UserFreezeRecord.currently_frozen_for?(object.id) }
  ) do
    record = UserFreezeRecord.currently_frozen_for(object.id)
    if record
      {
        frozen: true,
        reason: record.reason,
        reason_label: DiscourseFreeze::FREEZE_REASON_LABELS[record.reason],
        frozen_at: record.frozen_at.iso8601,
        frozen_by: record.frozen_by&.username
      }
    end
  end

  # Make frozen users' profiles visible even if they set hide_profile
  ::Guardian.class_eval do
    module FrozenProfileGuardianExtension
      def can_see_profile?(user)
        return true if UserFreezeRecord.currently_frozen_for?(user.id)
        super
      end
    end
    prepend FrozenProfileGuardianExtension
  end

  # Override profile_hidden in User serializer so frontend doesn't redirect
  add_to_serializer(:user, :profile_hidden) do
    UserFreezeRecord.currently_frozen_for?(object.id) ? false : object.user_option&.hide_profile
  end
end
