require 'pry'

class GitManager
  VALID_COMMANDS = ['add','commit','merge','checkout','co']

  def initialize(history_file)
    @history_file = history_file
    @command_list = []
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
      if VALID_COMMANDS.include?(command)
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
    when 'merge'
      "git reset --merge ORIG_HEAD"
    when 'checkout','co'
      "git checkout -"
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

end
