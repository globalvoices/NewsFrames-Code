class ProjectForm < ApplicationForm
  include ApplicationHelper

  attribute :project, Project, default: Project.new
  attribute :name, String, default: nil
  attribute :public, Boolean, default: nil
  attribute :global_checklists, Array, default: []
  attribute :deleted_global_checklists, Array, default: []
  attribute :selected_checklists, Array, default: []
  attribute :zombie_checklists, Array, default: []
  attribute :checklist_items, Hash, default: []
  attribute :zombie_checklist_items, Hash, default: []
  attribute :checklist_presenters, Hash, default: []

  validates :project, presence: true
  validates :name, presence: true

  ChecklistPresenter = Struct.new(:id, :name, :global_name, :enabled, :attached, :created_at)

  def initialize(attrs = {})
    super

    self.name ||= project.try(:name)

    if self.public.nil?
      self.public = project.try(:public) || false
    end

    self.selected_checklists ||= []
    self.zombie_checklists ||= []
    self.selected_checklists.reject!(&:empty?)
    self.zombie_checklists.reject!(&:empty?)

    unless attrs[:selected_checklists].present? # form initialization
      initialize_from_global_checklists
      initialize_from_project_checklists
    end

  end

  def initialize_from_global_checklists
    Checklist.all.each do |checklist|
      translated_checklist = checklist.with_translation_in_current_locale
      presenter = ChecklistPresenter.new(checklist.id,
                                         translated_checklist.name,
                                         translated_checklist.name,
                                         checklist.enabled,
                                         false,
                                         checklist.created_at)

      self.global_checklists.push(presenter)
      self.checklist_presenters[checklist.id] = presenter
      checklist_items[checklist.id] = []
      checklist.items.each do |entry|
        translated_entry = entry.with_translation_in_current_locale
        checklist_items[checklist.id].push(item: translated_entry.item, help: translated_entry.help)
      end
    end
  end

  def initialize_from_project_checklists
    project.checklists.each do |checklist|
      translated_checklist = checklist.with_translation_in_current_locale

      if checklist.global_checklist.present?
        self.selected_checklists.push(checklist.global_checklist.id)

        if self.checklist_presenters[checklist.global_checklist.id].present?
          self.checklist_presenters[checklist.global_checklist.id].name = translated_checklist.name
          self.checklist_presenters[checklist.global_checklist.id].attached = true
        end
      else
        self.zombie_checklists.push(checklist.id)
        self.deleted_global_checklists.push(ChecklistPresenter.new(checklist.id, translated_checklist.name))

        zombie_checklist_items[checklist.id] = []
        checklist.items.each do |entry|
          translated_entry = entry.with_translation_in_current_locale
          zombie_checklist_items[checklist.id].push(item: translated_entry.item, help: translated_entry.help)
        end
      end
    end
  end

  def self.permit
    [:name, :public, :selected_checklists => [], :zombie_checklists => []]
  end

  protected

  def persist!
    update_attributes

    globalize do
      ActiveRecord::Base.transaction do
        Projects::Save.(project: project, lead: project.lead.present? ? nil: user)
        project_checklist = ProjectChecklists::Associate.(project: project,
                                                          checklists: Checklist.find(selected_checklists),
                                                          zombie_checklists: ProjectChecklist.find(zombie_checklists))
      end
    end
  end

  private

  def update_attributes
    if project.present?
      project.name = self.name
      project.public = self.public
    end
  end
end
