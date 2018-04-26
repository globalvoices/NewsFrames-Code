class ApplicationForm
  include ActiveModel::Model
  include Virtus.model

  attribute :user, User, default: nil
  validates :user, presence: true

  def save!
    if valid?
      persist!
      true
    else
      false
    end
  end

  protected

  def persist!
    raise 'should be overridden'
  end
end