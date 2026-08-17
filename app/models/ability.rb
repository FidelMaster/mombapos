# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.owner? || user.admin?
      can :manage, :all
    elsif user.app_role.present?
      user.app_role.permissions.each do |permission|
        subject = if permission.subject_class == "all"
                    :all
                  else
                    permission.subject_class.safe_constantize || permission.subject_class.to_sym
                  end

        can permission.action.to_sym, subject
      end
    end
  end
end

