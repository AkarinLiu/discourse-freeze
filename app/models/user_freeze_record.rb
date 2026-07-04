# frozen_string_literal: true

class UserFreezeRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :frozen_by, class_name: "User"
  belongs_to :unfrozen_by, class_name: "User", optional: true

  validates :reason, inclusion: { in: DiscourseFreeze::FREEZE_REASONS }
  validates :frozen_at, presence: true

  scope :currently_frozen, -> { where(unfrozen_at: nil) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  def self.currently_frozen_for?(user_id)
    currently_frozen.for_user(user_id).exists?
  end

  def self.currently_frozen_for(user_id)
    currently_frozen.for_user(user_id).first
  end
end
