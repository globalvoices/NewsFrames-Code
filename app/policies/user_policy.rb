class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope.none
      end
    end
  end

  def index?
    admin?
  end

  def create?
    user.nil? or admin?
  end

  def show?
    user.present? and (user.id == record.id or user.admin?)
  end

  def update?
    show?
  end

  def approve?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin? && !record.admin?
  end

  private

  def admin?
    user.present? and user.admin?
  end
end