class CollaboratorPolicy < ApplicationPolicy
  def index?
    user?
  end

  def create_external?
    admin? || steward?
  end

  def create?
    create_external? || lead?
  end

  def destroy?
    # admin can remove any collaborator
    # leads can remove any collaborator (except sole lead)
    # non-leads can only remove themselves
    admin? || ((lead? || self?) && !sole_lead?)
  end

  def promote?
    admin? || lead?
  end

  private

  def lead?
    user? && record.present? && record.project.lead == user
  end

  def self?
    user? && user == record.user
  end

  def sole_lead?
    record.present? && record.lead && record.project.lead_collaborators.count == 1
  end
end
