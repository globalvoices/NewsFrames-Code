# == Schema Information
#
# Table name: collaborators
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  user_id    :integer          not null
#  lead       :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_3d4aaacbb1  (user_id => users.id)
#  fk_rails_5f612daf06  (project_id => projects.id)
#

class Collaborator < ApplicationRecord
  belongs_to :project
  belongs_to :user

  has_many :collaborator_checklists, dependent: :destroy
  alias_attribute :checklists, :collaborator_checklists

  validates :project, presence: true
  validates :user, presence: true
  validates :user, uniqueness: { scope: :project_id, message: 'is already a collaborator' }
  validate :validate_single_project_lead, if: :project

  def self.lead?(user_id)
    Collaborator.find_by(lead: true, user_id: user_id).present?
  end

  def has_checklist?(project_checklist)
    Collaborator.joins(:collaborator_checklists).where(id: id, checklists: { project_checklist_id: project_checklist.id }).present?
  end

  private

  def validate_single_project_lead
    if lead && project.lead.present? && project.lead != self.user
      errors.add(:lead, 'already exists')
    end
  end
end
