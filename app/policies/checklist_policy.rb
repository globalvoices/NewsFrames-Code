class ChecklistPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin?
        scope
      else
        scope.none
      end
    end
  end

  def import?
    admin?
  end

  def upload_checklist?
    admin?
  end

  def index?
    admin? or lead?
  end

  def create?
    admin?
  end

  def show?
    user?
  end

  def destroy?
    admin?
  end

  def edit_checklist?
    admin?
  end

  def overwrite?
    admin?
  end

  def add_translation?
    admin?
  end

  def show_translation?
    admin?
  end

  def edit_translation?
    admin?
  end

  def upload_translation?
    admin?
  end

  def overwrite_translation?
    admin?
  end

  def remove_translation?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end

  private

  def lead?
    user && Collaborator.lead?(user.id)
  end

end
