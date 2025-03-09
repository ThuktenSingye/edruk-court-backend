class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, :password, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  def jwt_payload
    super
  end
end
