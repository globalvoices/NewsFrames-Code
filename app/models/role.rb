# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  resource_type :string
#  resource_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource_type_and_resource_id           (resource_type,resource_id)
#

class Role < ApplicationRecord
  @@roles = ['admin', 'steward']

  has_and_belongs_to_many :users, :join_table => :users_roles

  belongs_to :resource,
             :polymorphic => true,
             :optional => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  validates :name, presence: true
  validates_inclusion_of :name, in: @@roles

  scopify

  def self.roles
    @@roles
  end
end
