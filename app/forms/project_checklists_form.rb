class ProjectChecklistsForm < ApplicationForm
  
  attribute :collaborator, Collaborator, default: Collaborator.new
  attribute :checklists, Array, default: []
  attribute :selected_checklist_items, Array

  validates :collaborator, presence: true

  def initialize(attrs = {})
    super
    
    self.selected_checklist_items ||= []
    self.selected_checklist_items.reject!(&:empty?)
    self.checklists = collaborator.checklists

    unless attrs[:selected_checklist_items].present? # form initialization
      self.checklists.each do |checklist|
        self.selected_checklist_items.push(*checklist.checked_items.map(&:id))
      end      
    else  # form submit
      self.selected_checklist_items.map!(&:to_i)
    end
  end

  def self.permit
    [:selected_checklist_items => []]
  end

  protected

  def persist!
    checklist_items = CollaboratorChecklistItem.find(selected_checklist_items)
    CollaboratorChecklists::CheckItems.(collaborator: collaborator, 
                                   checklist_items: checklist_items)
  end
end