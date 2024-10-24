class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :uploads, dependent: :destroy
  has_many :folders, dependent: :destroy
  has_many :binaries, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
