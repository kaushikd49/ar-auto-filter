require_relative "./sample_model_definitions"
require_relative "./db_setup_helper"


module DataLayerSetup
  include SampleModelDefinitions
  include DbSetupHelper

  def setup_datalayer(stdout_logging=false)
    do_db_setups(stdout_logging)
    create_tables()
  end
end
