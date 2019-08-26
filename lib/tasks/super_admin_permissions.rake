require 'rake'
namespace :super_admin_role do
  task :super_admin_permissions => :environment do
    Role.delete_all

    Role.create name: 'Super Admin'

    Permission.delete_all
    Permission.create(role_id: Role.first.id, entity_type: "Invoice", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Estimate", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Time Tracking", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Payment", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Client", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Item", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Taxes", can_read: true, can_update: true, can_delete: true, can_create: true)
    Permission.create(role_id: Role.first.id, entity_type: "Report", can_read: true)
    Permission.create(role_id: Role.first.id, entity_type: "Settings", can_read: true)

    User.all.each do |user|
      user.role = Role.first
      user.save
    end
  end
end