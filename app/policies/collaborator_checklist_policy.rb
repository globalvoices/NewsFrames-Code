class CollaboratorChecklistPolicy < ApplicationPolicy
  def index?
    admin? or collaborator?
  end

  def create?
    collaborator?
  end

  def show?
    collaborator? and self?
  end

  def destroy?
    collaborator? and self?
  end

  def check_item?
    collaborator? and self?
  end

  private

  def collaborator?
    user? && record.collaborator.project.users.include?(user)
  end

  def self?
    user? && record.collaborator.user.id == user.id
  end

end
