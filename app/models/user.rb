# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default(0)
#  approved               :boolean          default(FALSE), not null
#  author_id              :string
#  language               :string           default("eng"), not null
#  enabled                :boolean          default(TRUE), not null
#  initials               :string
#
# Indexes
#
#  index_users_on_approved              (approved)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_enabled               (enabled)
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  attr_accessor :name_required

  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, password_length: 8..128

  validates :email, :encrypted_password, presence: true
  validates_email_format_of :email, message: 'is not a valid email address.'
  validates :name, presence: true, if: :name_required
  validates :language, presence: true
  validates :initials, length: { maximum: 10 }

  def admin?
    has_role? :admin
  end

  def steward?
    has_role? :steward
  end

  def active_for_authentication?
    super && approved? && enabled?
  end

  def inactive_message
    return :not_approved if !approved?
    return :not_enabled if !enabled?
    super
  end

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif !recoverable.enabled?
      recoverable.errors[:base] << I18n.t("devise.failure.not_enabled")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end

  def self.ransackable_scopes(auth_object = nil)
    [ :with_role ]
  end

  def display_name
    if name.present?
      "#{name} (#{email})"
    else
      email
    end
  end

  def short_name
    initials || computed_initials || email
  end

  private

  def computed_initials
    if name.present?
      names = name.split(' ')
      if names.length > 1
        names.map(&:first).join
      end
    end
  end
end
