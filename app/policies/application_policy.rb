class ApplicationPolicy < Struct.new(:user, :record)
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end

    private

    def user?
      user.present? && user.approved?
    end

    def admin?
      user? && user.admin?
    end
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def user?
    user.present? && user.approved?
  end

  def admin?
    user? && user.admin?
  end

  def steward?
    user? && user.steward?
  end
end
