class ProjectPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user?
        if admin?
          scope
        else
          collaborating_scope = scope.collaborating(user)
          public_scope = scope.where(public: true)
          collaborating_scope.union(public_scope)
        end
      else
        scope.where(public: true)
      end
    end
  end

  def index?
    true
  end

  def create?
    user?
  end

  def show?
    record.public || collaborate?
  end

  def collaborate?
    user? && (admin? || lead? || collaborator?)
  end

  def pads?
    show?
  end

  def update?
    user? && (admin? || lead?)
  end

  def destroy?
    admin?
  end

  def checklist_report?
    admin? or lead?
  end

  private

  def lead?
    user? && record.lead == user
  end

  def collaborator?
    user? && record.users.include?(user)
  end
end
