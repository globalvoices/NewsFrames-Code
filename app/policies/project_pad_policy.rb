class ProjectPadPolicy < ApplicationPolicy
  def create?
    ProjectPolicy.new(user, record.project).collaborate?
  end

  def update?
    create?
  end

  def destroy?
    update? && !primary_pad?
  end

  private

  def primary_pad?
    record == record.project.primary_pad
  end
end
