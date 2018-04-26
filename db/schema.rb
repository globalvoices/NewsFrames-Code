# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180410171948) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checklist_item_translations", force: :cascade do |t|
    t.integer  "checklist_item_id", null: false
    t.string   "locale",            null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "item"
    t.string   "help"
    t.index ["checklist_item_id"], name: "index_checklist_item_translations_on_checklist_item_id", using: :btree
    t.index ["locale"], name: "index_checklist_item_translations_on_locale", using: :btree
  end

  create_table "checklist_items", force: :cascade do |t|
    t.integer  "checklist_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "checklist_translations", force: :cascade do |t|
    t.integer  "checklist_id", null: false
    t.string   "locale",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name"
    t.index ["checklist_id"], name: "index_checklist_translations_on_checklist_id", using: :btree
    t.index ["locale"], name: "index_checklist_translations_on_locale", using: :btree
  end

  create_table "checklists", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "enabled",    default: true, null: false
  end

  create_table "collaborator_checklist_items", force: :cascade do |t|
    t.integer  "collaborator_checklist_id",                 null: false
    t.integer  "project_checklist_item_id",                 null: false
    t.boolean  "checked",                   default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["collaborator_checklist_id", "project_checklist_item_id"], name: "index_collaborator_checklist_items_checklist_id_item_id", unique: true, using: :btree
  end

  create_table "collaborator_checklists", force: :cascade do |t|
    t.integer  "collaborator_id",      null: false
    t.integer  "project_checklist_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["collaborator_id", "project_checklist_id"], name: "index_collaborator_checklists_collaborator_id_proj_chklst_id", unique: true, using: :btree
  end

  create_table "collaborators", force: :cascade do |t|
    t.integer  "project_id",                 null: false
    t.integer  "user_id",                    null: false
    t.boolean  "lead",       default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "meme_mappers", force: :cascade do |t|
    t.integer  "project_id",                   null: false
    t.string   "name"
    t.string   "image_url",                    null: false
    t.binary   "serialized_data", default: "", null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "project_checklist_item_translations", force: :cascade do |t|
    t.integer  "project_checklist_item_id", null: false
    t.string   "locale",                    null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "item"
    t.string   "help"
    t.index ["locale"], name: "index_project_checklist_item_translations_on_locale", using: :btree
    t.index ["project_checklist_item_id"], name: "index_1b2338e6d5def8c7a5198ac5d983b09e5b6e0de8", using: :btree
  end

  create_table "project_checklist_items", force: :cascade do |t|
    t.integer  "project_checklist_id", null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "project_checklist_translations", force: :cascade do |t|
    t.integer  "project_checklist_id", null: false
    t.string   "locale",               null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "name"
    t.index ["locale"], name: "index_project_checklist_translations_on_locale", using: :btree
    t.index ["project_checklist_id"], name: "index_project_checklist_translations_on_project_checklist_id", using: :btree
  end

  create_table "project_checklists", force: :cascade do |t|
    t.integer  "project_id",   null: false
    t.integer  "checklist_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "project_pads", force: :cascade do |t|
    t.integer  "project_id", null: false
    t.string   "pad_id",     null: false
    t.string   "name",       null: false
    t.integer  "index",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "index"], name: "index_project_pads_on_project_id_and_index", unique: true, using: :btree
    t.index ["project_id", "pad_id"], name: "index_project_pads_on_project_id_and_pad_id", unique: true, using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "public",     default: false, null: false
  end

  create_table "queries", force: :cascade do |t|
    t.integer  "project_id",                      null: false
    t.string   "media_cloud_url",                 null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "name"
    t.boolean  "full_data",       default: false, null: false
    t.binary   "serialized_data"
    t.boolean  "migrated",        default: false, null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                  null: false
    t.string   "encrypted_password",                     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "name"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.boolean  "approved",               default: false, null: false
    t.string   "author_id"
    t.boolean  "enabled",                default: true,  null: false
    t.string   "language",               default: "eng", null: false
    t.string   "initials"
    t.index ["approved"], name: "index_users_on_approved", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["enabled"], name: "index_users_on_enabled", using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id", using: :btree
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
    t.index ["user_id"], name: "index_users_roles_on_user_id", using: :btree
  end

  add_foreign_key "checklist_items", "checklists"
  add_foreign_key "collaborator_checklist_items", "collaborator_checklists"
  add_foreign_key "collaborator_checklist_items", "project_checklist_items"
  add_foreign_key "collaborator_checklists", "collaborators"
  add_foreign_key "collaborator_checklists", "project_checklists"
  add_foreign_key "collaborators", "projects"
  add_foreign_key "collaborators", "users"
  add_foreign_key "meme_mappers", "projects"
  add_foreign_key "project_checklist_items", "project_checklists"
  add_foreign_key "project_checklists", "checklists"
  add_foreign_key "project_checklists", "projects"
  add_foreign_key "project_pads", "projects"
  add_foreign_key "queries", "projects"
end
