module Trackstamps
  extend ActiveSupport::Concern

  included do

    before_save :set_updater
    before_create :set_creator

    define_method :updater do
      User.find self.send(:updated_by)
    end

    define_method :creator do
      User.find self.send(:created_by)
    end

    define_method "#{:updater}=" do |user|
      self.send("#{:updated_by}=", user.id)
    end

    define_method "#{:creator}=" do |user|
      self.send("#{:created_by}=", user.id)
    end

    protected

    def set_updater
      return unless Trackstamps.current_user
      self.send("#{:updated_by}=", Trackstamps.current_user.id)
    end

    def set_creator
      return unless Trackstamps.current_user
      self.send("#{:created_by}=", Trackstamps.current_user.id) if self.created_by.nil?
    end

  end

  class << self
    def current_user
      Thread.current[:current_user]
    end
  end

end