# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public     :boolean          default(FALSE), not null
#

class Project < ApplicationRecord
  has_many :collaborators, dependent: :destroy
  has_many :users, through: :collaborators
  has_many :project_checklists, dependent: :destroy
  has_many :project_pads, dependent: :destroy
  has_many :queries, dependent: :destroy
  has_many :meme_mappers, dependent: :destroy

  alias_attribute :checklists, :project_checklists

  validates :name, presence: true

  scope :collaborating, -> (user) { joins(:collaborators).where(collaborators: { user_id: user.id }) }
  scope :lead, -> { joins(:collaborators).where(collaborators: { lead: true }) }
  scope :nonlead, -> { joins(:collaborators).where(collaborators: { lead: false }) }

  def lead_collaborators
    collaborators.where(lead: true)
  end

  def lead
    lead_collaborators.first.try(:user)
  end

  def primary_pad
    project_pads.order(:index).first
  end

  def has_checklist?(checklist)
    Project.joins(:project_checklists).where(id: id, checklists: { checklist_id: checklist.id }).present?
  end

  def progress
    return 0 unless checklists.present?
    total_item_count = checklists.reduce(0) { |total, chklst| total + chklst.item_count }
    total_checked_count = checklists.reduce(0) { |total, chklst| total + chklst.checked_count }
    value = total_checked_count.to_f / total_item_count * 100
    value.nan? ? 0 : value
  end
end
