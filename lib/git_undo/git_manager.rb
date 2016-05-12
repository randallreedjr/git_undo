class GitManager
  def initialize(history_file)
    @history_file = history_file
    @command_list = []
  end

  def get_commands
    File.open(@history_file) do |file|
      file.each do |line|
        # find last git command
        if /\Agit / =~ line
          @command_list << line.chomp
        end
      end
    end
  end

  def last_command
    @command_list.last
  end

  def run
    get_commands
    puts "Last git command was: `#{last_command}`"
  end
end
