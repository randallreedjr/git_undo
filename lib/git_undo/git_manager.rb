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

  def self.setup
    puts "It looks like you haven't run the initial setup. Would you like to do so now (y/n)?"
    if gets.chomp.downcase == 'y'
      puts "This will involve appending an alias to your .bash_profile. Okay to proceed?"
      if gets.chomp.downcase == 'y'
        puts "Thanks!"
        update_bash_profile
      else
        puts "Goodbye!"
      end
    else
      puts "Goodbye!"
    end
  end

  def self.update_bash_profile
    alias_exists = false
    # last_line_alias = false
    # position = 0
    # line_count = 0
    # index = 0
    # max_line_count = 0
    file = File.open(File.expand_path('~' + '/.bash_profile'),'r+')

    file.readlines.each do |line|
      # line_count += 1
      if /\A[\s]*alias/.match line
        if /\A[\s]*alias gitundo="HISTFILE=\$HISTFILE gitundo"\n\z/.match line
          alias_exists = true
        end
        # max_line_count = line_count
      # elsif last_line_alias
      #   position = file.pos
      #   last_line_alias = false
      end
    end
    unless alias_exists
      file.write("# Git Undo\n")
      file.write("alias gitundo=\"HISTFILE=$HISTFILE gitundo\"\n")
      puts "Please run `source ~/.bash_profile && cd .` to reload configuration"
    end
    file.close
    # puts max_line_count + 1
    # puts position
  end
end
