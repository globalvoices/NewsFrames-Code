module ActiveAdmin
  class PagePolicy < ApplicationPolicy
    def show?
      case record.name
      when 'Dashboard'
        user.present? and user.admin?
      else
        false
      end
    end
  end
end