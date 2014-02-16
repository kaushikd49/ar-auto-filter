module DbSetupHelper
  include SampleModelDefinitions

  DATABASE = 'experiments'
  CONNECTION_SPEC = {adapter: 'mysql2', username: 'root', password: '', host: 'localhost'}

  def do_db_setups(stdout_logging=false)
    establish_connection_with_no_db(CONNECTION_SPEC)
    create_database(DATABASE)
    establish_connection_with_db(DATABASE, CONNECTION_SPEC)
    ActiveRecord::Base.logger = Logger.new(STDOUT) if stdout_logging
  end

  def create_database(database)
    ActiveRecord::Base.connection.create_database(database) rescue nil
  end

  def establish_connection_with_no_db(connection_spec)
    ActiveRecord::Base.establish_connection(connection_spec)
  end

  def establish_connection_with_db(database, connection_spec)
    ActiveRecord::Base.establish_connection(connection_spec.merge(database: database))
  end
end