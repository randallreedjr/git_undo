require 'pry'

class GitManager
  def valid_commands
    ['add','commit']
  end

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
    last = ''
    index = @command_list.length - 1
    while last.empty? && index >= 0
      command = parse_command(@command_list[index])[:action]
      if valid_commands.include?(command)
        last = @command_list[index]
      end
      index -= 1
    end
    return last
  end

  def parse_command(command)
    tokens = command.split(' ')
    action = tokens[1]
    arguments = tokens[2..-1].join(' ')
    return { action: action, arguments: arguments }
  end

  def undo_command(action, arguments)
    case action
    when 'add'
      "git reset #{arguments}"
    when 'commit'
      "git reset --soft HEAD~"
    end
  end

  def undo_message(command)
    command_hash = parse_command(command)
    undo = undo_command(command_hash[:action], command_hash[:arguments])
    if !undo
      puts "Sorry, I don't know how to undo that command"
    else
      puts "To undo, run `#{undo}`\nWould you like to automatically run this command now? (y/N)"
      option = gets.chomp.downcase
      if option == 'y'
        puts undo
        %x[ #{undo} ]
      end
    end
  end

  def run
    get_commands
    if last_command
      puts "Last git command was: `#{last_command}`"
      undo_message(last_command)
    else
      puts "No git commands found!"
    end
  end

  def self.setup
    puts "It looks like you haven't run the initial setup. Would you like to do so now? (y/N)"
    if gets.chomp.downcase == 'y'
      puts "This will involve appending an alias to your .bash_profile. Okay to proceed? (y/N)"
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
      file.write("# Flush history immediately")
      file.write("export PROMPT_COMMAND='history -a")
      puts "Please run `source ~/.bash_profile && cd .` to reload configuration"
    end
    file.close
    # puts max_line_count + 1
    # puts position
  end
end
