class WsgiPlugin < StagingPlugin
  # TODO - Is there a way to avoid this without some kind of 'register' callback?
  # e.g. StagingPlugin.register('sinatra', __FILE__)
  def framework
    'wsgi'
  end

  def stage_application
    Dir.chdir(destination_directory) do
      create_app_directories
      copy_source_files
      create_startup_script
    end
  end

  # Let DEA fill in as needed..
  def start_command
    "%VCAP_LOCAL_RUNTIME% #{detect_main_file} $@"
  end

  private
  def startup_script
    vars = environment_hash
    generate_startup_script(vars)
  end

  def detect_main_file
    file, py_files = nil, app_files_matching_patterns

    if py_files.length == 1
      file = py_files.first
    else
      # We need to make this smarter, and then allow client to choose or
      # send us a hint.

      ['index.py', 'app.py', 'web.py'].each do |fname|
        file = fname if py_files.include? fname
      end
    end

    # TODO - Currently staging exceptions are not handled well.
    # Convert to using exit status and return value on a case-by-case basis.
    raise "Unable to determine a wsgi startup command" unless file
    file
  end
end
