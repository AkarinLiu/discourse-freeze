# frozen_string_literal: true

module ::DiscourseFreeze
  class FreezeController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    before_action :ensure_admin

    def list
      frozen_records =
        UserFreezeRecord.currently_frozen.includes(:user, :frozen_by).order(frozen_at: :desc)

      serialized =
        frozen_records.map do |record|
          {
            id: record.id,
            user_id: record.user_id,
            username: record.user.username,
            name: record.user.name,
            reason: record.reason,
            reason_label: DiscourseFreeze::FREEZE_REASON_LABELS[record.reason] || record.reason,
            frozen_by: record.frozen_by.username,
            frozen_at: record.frozen_at,
          }
        end

      render json: { frozen_users: serialized }
    end

    def create
      user = User.find_by(id: params[:user_id])
      raise Discourse::NotFound if user.blank?

      if DiscourseFreeze::FREEZE_REASONS.exclude?(params[:reason])
        raise Discourse::InvalidParameters.new(:reason)
      end

      if UserFreezeRecord.currently_frozen_for?(user.id)
        return render_json_error I18n.t("freeze.errors.already_frozen")
      end

      if user.id == current_user.id
        return render_json_error I18n.t("freeze.errors.cannot_freeze_self")
      end

      record =
        UserFreezeRecord.create!(
          user_id: user.id,
          frozen_by_id: current_user.id,
          reason: params[:reason],
          frozen_at: Time.zone.now,
        )

      StaffActionLogger.new(current_user).log_custom(
        "freeze_user",
        user_id: user.id,
        username: user.username,
        reason: params[:reason],
      )

      render json: success_json
    end

    def revoke
      user = User.find_by(id: params[:user_id])
      raise Discourse::NotFound if user.blank?

      record = UserFreezeRecord.currently_frozen_for(user.id)
      raise Discourse::NotFound if record.blank?

      record.update!(unfrozen_by_id: current_user.id, unfrozen_at: Time.zone.now)

      StaffActionLogger.new(current_user).log_custom(
        "unfreeze_user",
        user_id: user.id,
        username: user.username,
      )

      render json: success_json
    end

    def search_users
      term = params[:q]
      raise Discourse::InvalidParameters.new(:q) if term.blank?

      users =
        User
          .joins(:user_emails)
          .where("username ILIKE :q OR user_emails.email ILIKE :q", q: "%#{term}%")
          .where.not(id: current_user.id)
          .limit(20)
          .select(:id, :username, :name)
          .distinct

      render json: {
               users:
                 users.map { |u| { id: u.id, username: u.username, name: u.name } }
             }
    end

    private

    def ensure_admin
      raise Discourse::InvalidAccess.new unless current_user&.admin?
    end
  end
end
