class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :read, News
    
    if user.is?(:admin) || user.is?(:spindelman)
      can :manage, :all
    end

    if user.is? :sanningsspridare
      can :manage, News
    end

    if user.is? :styrelse
      can :manage, News
    end
  end
end
