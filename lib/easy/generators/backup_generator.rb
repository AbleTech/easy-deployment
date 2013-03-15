require 'rails/generators'

module Easy
  class BackupGenerator < Rails::Generators::Base
    source_root File.join(File.dirname(__FILE__), "templates") # Where templates are copied from

    include GeneratorHelpers

    desc %{Generates a backup config set to run nightly and upload to S3}

    def create_backup_files
      gem_group(:backup) do
        gem "whenever", :require => false
        case Rails::VERSION::MAJOR
        when 3
          gem "backup", "~> 3.0.27", :require => false
          gem "fog",    "~> 1.4.0",  :require => false
          gem "mail",   "~> 2.4.0",  :require => false
        when 4
          gem "backup", "~> 3.1.3",   :require => false
          gem "fog",     "~> 1.9.0",  :require => false
          gem "net-ssh", "<= 2.5.2",  :require => false # Greater than >= 2.3.0 as well, though we can't express that
          gem "net-scp", "<= 1.0.4",  :require => false # Greater than 1.0.0
          gem "excon",   "~> 0.17.0", :require => false
          gem "mail",    "~> 2.5.0",  :require => false
        else
          warn "Unsupported rails release detected. You'll need to manage your own dependencies for the backup gem"
          gem "backup", :require => false
        end
      end

      template("backup.rb.tt", "config/backup.rb")
      template("schedule.rb.tt", "config/schedule.rb")
      copy_file("s3.yml", "config/s3.yml")

      run("bundle install")

      say("Backup configuration generated", :green)
      say("  - TODO: edit config/backup.rb setting notification addresses and other configuration options", :green)
      say("  - TODO: ensure your S3 keys are set in config/s3.yml", :green)

      true
    end

  end
end
