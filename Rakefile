require 'active_record'
require 'active_support/core_ext/string/strip'
require 'fileutils'
require 'yaml'
require 'erb'

module ActiveRecordTasks
  extend self

  def connect
    # Sets up database configuration
    db = URI.parse(ENV['DATABASE_URL']) if ENV['DATABASE_URL']
    if db && db.scheme == 'postgres' # Heroku environment
      ActiveRecord::Base.establish_connection(
        :adapter  => db.scheme,
        :host     => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..-1]
      )
    else # local environment
      environment = ENV['RACK_ENV'] || 'development'
      db = YAML.load(ERB.new(File.read('config/database.yml')).result)[environment]
      ActiveRecord::Base.establish_connection(db)
    end
  end

  def create
    environment = ENV['RACK_ENV'] || 'development'
    db = YAML.load(ERB.new(File.read('config/database.yml')).result)[environment]
    ActiveRecord::Base.establish_connection(db.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.create_database db['database']
  end

  def drop
    environment = ENV['RACK_ENV'] || 'development'
    db = YAML.load(ERB.new(File.read('config/database.yml')).result)[environment]
    ActiveRecord::Base.establish_connection(db.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.drop_database db['database']
  end

  def create_migration(migration_name, version = nil)
    raise "No NAME specified. Example usage: `rake db:create_migration NAME=create_users`" if migration_name.nil?

    migration_number = version || Time.now.utc.strftime("%Y%m%d%H%M%S")
    migration_file = File.join(migrations_dir, "#{migration_number}_#{migration_name}.rb")
    migration_class = migration_name.split("_").map(&:capitalize).join

    FileUtils.mkdir_p(migrations_dir)
    File.open(migration_file, 'w') do |file|
      file.write <<-MIGRATION.strip_heredoc
        class #{migration_class} < ActiveRecord::Migration
          def up
          end

          def down
          end
        end
      MIGRATION
    end
  end

  def migrate(version = nil)
    silence_activerecord do
      migration_version = version ? version.to_i : version
      ActiveRecord::Migrator.migrate(migrations_dir, migration_version)
    end
  end

  def rollback(step = nil)
    silence_activerecord do
      migration_step = step ? step.to_i : 1
      ActiveRecord::Migrator.rollback(migrations_dir, migration_step)
    end
  end

  def dump_schema(file_name = 'db/schema.rb')
    silence_activerecord do
      ActiveRecord::Migration.suppress_messages do
        # Create file
        out = File.new(file_name, 'w')

        # Load schema
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, out)

        out.close
      end
    end
  end

  def load_schema(file_name = 'db/schema.rb')
    load(file_name)
  end

  private

  def migrations_dir
    ActiveRecord::Migrator.migrations_paths.first
  end

  def silence_activerecord(&block)
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    yield if block_given?
    ActiveRecord::Base.logger = old_logger
  end
end

namespace :db do
  desc "establish connection"
  task :connect_db do
    ActiveRecordTasks.connect
  end

  desc "create the database"
  task :create do
    ActiveRecordTasks.create
  end

  desc "drop the database"
  task :drop => :connect_db do
    ActiveRecordTasks.drop
  end

  desc "create an ActiveRecord migration"
  task :create_migration => :connect_db do
    ActiveRecordTasks.create_migration(ENV["NAME"], ENV["VERSION"])
  end

  desc "migrate the database (use version with VERSION=n)"
  task :migrate => :connect_db do
    ActiveRecordTasks.migrate(ENV["VERSION"])
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  desc "roll back the migration (use steps with STEP=n)"
  task :rollback => :connect_db do
    ActiveRecordTasks.rollback(ENV["STEP"])
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :schema do
    desc "dump schema into file"
    task :dump do
      ActiveRecordTasks.dump_schema()
    end

    desc "load schema into database"
    task :load do
      ActiveRecordTasks.load_schema()
    end
  end
end
